#!/usr/bin/env python3
"""
Meshy.ai Asset Generator for Husky Raid
Generates 3D assets using Meshy.ai API
"""

import os
import json
import time
import requests
from pathlib import Path

API_KEY = os.environ.get("MESHY_API_KEY")
BASE_URL = "https://api.meshy.ai"
OUTPUT_DIR = Path("assets/models")

ASSETS = {
    "players": [
        {
            "name": "player_red",
            "prompt": "Sci-fi supersoldier, geometric armor, bold silhouette, red high-saturation armor, scuffed metal PBR textures, hexagonal undersuit pattern, Halo style, game-ready low poly",
            "texture_prompt": "Red armor with scuffed metal, worn combat marks, hexagonal rubberized undersuit, high saturation red, military sci-fi",
        },
        {
            "name": "player_blue",
            "prompt": "Sci-fi supersoldier, geometric armor, bold silhouette, blue high-saturation armor, scuffed metal PBR textures, hexagonal undersuit pattern, Halo style, game-ready low poly",
            "texture_prompt": "Blue armor with scuffed metal, worn combat marks, hexagonal rubberized undersuit, high saturation blue, military sci-fi",
        },
    ],
    "weapons": [
        {
            "name": "assault_rifle",
            "prompt": "Sci-fi assault rifle, geometric low-poly, bold shape, scuffed metal and polymer textures, used-future realism, Halo style weapon, game-ready",
            "texture_prompt": "Military tan and grey metal, scuffed polymer, worn battle damage, realistic metal roughness",
        },
        {
            "name": "pistol",
            "prompt": "Sci-fi pistol handgun, geometric low-poly, bold shape, scuffed metal and polymer textures, used-future realism, Halo style, game-ready",
            "texture_prompt": "Black polymer and silver metal, scuffed grip, worn finish, realistic roughness",
        },
        {
            "name": "shotgun",
            "prompt": "Sci-fi pump shotgun, geometric low-poly, bold shape, scuffed metal and wood textures, used-future realism, Halo style, game-ready",
            "texture_prompt": "Black metal and brown wood, scuffed worn finish, realistic roughness and metallic",
        },
        {
            "name": "sniper",
            "prompt": "Sci-fi sniper rifle, geometric low-poly, long barrel, bold shape, scuffed metal textures, used-future realism, Halo style, game-ready",
            "texture_prompt": "Camo green and black metal, sniper scope, scuffed worn finish, realistic PBR",
        },
        {
            "name": "rocket_launcher",
            "prompt": "Sci-fi rocket launcher, geometric low-poly, bold chunky shape, tube launcher, scuffed metal textures, used-future realism, Halo style, game-ready",
            "texture_prompt": "Green military metal and black polymer, rocket tubes, scuffed worn combat, realistic roughness",
        },
        {
            "name": "energy_sword",
            "prompt": "Sci-fi energy sword, geometric low-poly, glowing blade handle, bold hilt shape, scuffed metal textures, Halo style, game-ready",
            "texture_prompt": "Silver metal hilt, energy glow effect, scuffed worn metal, realistic metallic roughness",
        },
    ],
    "flags": [
        {
            "name": "flag_red",
            "prompt": "Tall flag on pole, geometric simple triangular flag shape, bright red color, metallic pole, sci-fi style, game-ready low poly",
            "texture_prompt": "Bright red fabric flag, metallic silver pole, sci-fi minimalist",
        },
        {
            "name": "flag_blue",
            "prompt": "Tall flag on pole, geometric simple triangular flag shape, bright blue color, metallic pole, sci-fi style, game-ready low poly",
            "texture_prompt": "Bright blue fabric flag, metallic silver pole, sci-fi minimalist",
        },
    ],
    "props": [
        {
            "name": "crate_sci-fi",
            "prompt": "Sci-fi crate, geometric box, angular edges, metal construction, sci-fi industrial, game-ready low poly",
            "texture_prompt": "Grey metal crate, industrial sci-fi markings, scuffed worn metal, realistic roughness",
        },
        {
            "name": "pillar_sci-fi",
            "prompt": "Sci-fi pillar, geometric hexagonal, glowing accent lines, brutalist architecture, Halo Forerunner style, game-ready",
            "texture_prompt": "Grey metallic pillar, glowing blue accent lines, brutalist sci-fi, worn edges",
        },
        {
            "name": "cover_block",
            "prompt": "Sci-fi cover block, geometric angular, low profile, metal construction, military sci-fi, game-ready",
            "texture_prompt": "Green military metal, angular cover, scuffed combat wear, realistic roughness",
        },
        {
            "name": "weapon_pad",
            "prompt": "Sci-fi weapon pickup pad, geometric circular platform, glowing border, Halo style, game-ready low poly",
            "texture_prompt": "Metallic platform with glowing cyan border, sci-fi energy effect, low poly",
        },
    ],
}


def create_preview_task(prompt: str, name: str) -> str:
    """Create a preview task and return the task ID"""
    url = f"{BASE_URL}/openapi/v2/text-to-3d"
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    data = {
        "mode": "preview",
        "prompt": prompt,
        "ai_model": "meshy-6",
        "should_remesh": True,
        "target_polycount": 10000,
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        result = response.json()
        task_id = result.get("result")
        print(f"Created preview task for {name}: {task_id}")
        return task_id
    else:
        print(f"Error creating preview for {name}: {response.text}")
        return None


def create_refine_task(preview_task_id: str, texture_prompt: str, name: str) -> str:
    """Create a refine task with PBR texturing"""
    url = f"{BASE_URL}/openapi/v2/text-to-3d"
    headers = {"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"}
    data = {
        "mode": "refine",
        "preview_task_id": preview_task_id,
        "enable_pbr": True,
        "texture_prompt": texture_prompt,
        "ai_model": "latest",
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        result = response.json()
        task_id = result.get("result")
        print(f"Created refine task for {name}: {task_id}")
        return task_id
    else:
        print(f"Error creating refine for {name}: {response.text}")
        return None


def check_task_status(task_id: str) -> dict:
    """Check the status of a task"""
    url = f"{BASE_URL}/openapi/v2/text-to-3d/{task_id}"
    headers = {"Authorization": f"Bearer {API_KEY}"}

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    return None


def wait_for_task(task_id: str, name: str, max_wait: int = 300) -> dict:
    """Wait for a task to complete"""
    print(f"Waiting for {name} ({task_id})...")
    start_time = time.time()

    while time.time() - start_time < max_wait:
        status = check_task_status(task_id)
        if status:
            progress = status.get("progress", 0)
            task_status = status.get("status", "PENDING")
            print(f"  {name}: {task_status} ({progress}%)")

            if task_status == "SUCCEEDED":
                return status
            elif task_status == "FAILED":
                print(
                    f"  Task failed: {status.get('task_error', {}).get('message', 'Unknown error')}"
                )
                return None

        time.sleep(10)

    print(f"  Timeout waiting for {name}")
    return None


def download_model(task_result: dict, name: str, category: str) -> bool:
    """Download the GLB model"""
    model_urls = task_result.get("model_urls", {})
    glb_url = model_urls.get("glb")

    if not glb_url:
        print(f"No GLB URL for {name}")
        return False

    output_path = OUTPUT_DIR / category / f"{name}.glb"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    print(f"Downloading {name} to {output_path}...")
    response = requests.get(glb_url, stream=True)

    if response.status_code == 200:
        with open(output_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"  Downloaded: {output_path}")
        return True
    else:
        print(f"  Download failed: {response.status_code}")
        return False


def generate_asset(name: str, prompt: str, texture_prompt: str, category: str) -> bool:
    """Generate a complete asset with preview and refine"""
    print(f"\n=== Generating {name} ===")
    print(f"Prompt: {prompt}")

    preview_id = create_preview_task(prompt, name)
    if not preview_id:
        return False

    preview_result = wait_for_task(preview_id, f"{name} preview")
    if not preview_result:
        return False

    refine_id = create_refine_task(preview_id, texture_prompt, name)
    if not refine_id:
        return False

    refine_result = wait_for_task(refine_id, f"{name} refine")
    if not refine_result:
        return False

    return download_model(refine_result, name, category)


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("HUSKY RAID - Meshy.ai Asset Generator")
    print("=" * 60)

    # Generate players first
    print("\n" + "=" * 60)
    print("PHASE 1: PLAYERS")
    print("=" * 60)

    for player in ASSETS["players"]:
        generate_asset(
            player["name"], player["prompt"], player["texture_prompt"], "players"
        )

    # Generate weapons
    print("\n" + "=" * 60)
    print("PHASE 2: WEAPONS")
    print("=" * 60)

    for weapon in ASSETS["weapons"]:
        generate_asset(
            weapon["name"], weapon["prompt"], weapon["texture_prompt"], "weapons"
        )

    print("\n" + "=" * 60)
    print("Asset generation complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
