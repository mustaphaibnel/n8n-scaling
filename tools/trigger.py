#!/usr/bin/env python3
import os, sys, requests, json

url = os.getenv("N8N_WEBHOOK_URL")
if not url:
    sys.exit("❌  Set N8N_WEBHOOK_URL")

headers = {"Content-Type": "application/json"}
token = os.getenv("N8N_API_TOKEN")
if token:
    headers["Authorization"] = f"Bearer {token}"

auth = None
user = os.getenv("N8N_BASIC_AUTH_USER")
pwd  = os.getenv("N8N_BASIC_AUTH_PASSWORD")
if user and pwd:
    auth = (user, pwd)

payload = {"name": "Mustapha", "source": "trigger.py demo"}
print(f"POST {url} → {payload}")
r = requests.post(url, json=payload, headers=headers, auth=auth, timeout=10)
print(f"[{r.status_code}] {r.text}")
r.raise_for_status()
