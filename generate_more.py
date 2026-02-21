#!/usr/bin/env python3
"""
Asset Generator - Run this to generate more models
Usage: python3 generate_more.py
"""

import requests, time, os

API_KEY = os.environ.get("MESHY_API_KEY")

print(f"Using Meshy API Key: {API_KEY}")

BASE_URL = "https://api.meshy.ai"

ASSETS = [
    (
        "player_blue",
        "Sci-fi supersoldier, geometric armor, blue high-saturation armor, Halo style",
        "Blue armor",
        "players",
    ),
    (
        "pistol",
        "Sci-fi pistol handgun, geometric low-poly, Halo style",
        "Black polymer pistol",
        "weapons",
    ),
    (
        "shotgun",
        "Sci-fi pump shotgun, geometric low-poly, Halo style",
        "Black metal shotgun",
        "weapons",
    ),
    (
        "sniper",
        "Sci-fi sniper rifle, geometric low-poly, Halo style",
        "Camo sniper rifle",
        "weapons",
    ),
    (
        "rocket_launcher",
        "Sci-fi rocket launcher, geometric low-poly, Halo style",
        "Green rocket launcher",
        "weapons",
    ),
    (
        "energy_sword",
        "Sci-fi energy sword, geometric low-poly, Halo style",
        "Silver energy sword",
        "weapons",
    ),
    ("flag_red", "Red flag on pole, geometric simple, sci-fi", "Red flag", "flags"),
    ("flag_blue", "Blue flag on pole, geometric simple, sci-fi", "Blue flag", "flags"),
]


def wait_task(tid):
    while True:
        s = requests.get(
            f"{BASE_URL}/openapi/v2/text-to-3d/{tid}",
            headers={"Authorization": f"Bearer {API_KEY}"},
        ).json()
        print(f"  {s.get('status')} ({s.get('progress')}%)")
        if s.get("status") == "SUCCEEDED":
            return s
        if s.get("status") == "FAILED":
            return None
        time.sleep(15)


def gen(name, prompt, texture, folder):
    print(f"\n=== {name} ===")
    
    # Define headers once to reuse
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    r = requests.post(
        f"{BASE_URL}/openapi/v2/text-to-3d",
        headers=headers,
        json={
            "mode": "preview",
            "prompt": prompt,
            "ai_model": "meshy-6",
            "should_remesh": True,
        },
    )
    pid = r.json().get("result")
    print(f"Preview: {pid}")
    if not (s := wait_task(pid)):
        return

    r = requests.post(
        f"{BASE_URL}/openapi/v2/text-to-3d",
        headers=headers,
        json={
            "mode": "refine",
            "preview_task_id": pid,
            "enable_pbr": True,
            "texture_prompt": texture,
        },
    )
    rid = r.json().get("result")
    print(f"Refine: {rid}")
    if not (s := wait_task(rid)):
        return

    os.makedirs(f"assets/models/{folder}", exist_ok=True)
    url = s.get("model_urls", {}).get("glb")
    if url:
        open(f"assets/models/{folder}/{name}.glb", "wb").write(
            requests.get(url).content
        )
        print(f"Saved: assets/models/{folder}/{name}.glb")


if __name__ == "__main__":
    for a in ASSETS:
        gen(*a)
