"""Test which free models are actually responding right now."""
import os, sys, json
sys.path.insert(0, os.path.dirname(__file__))
from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'), override=True)

KEY = os.getenv("CHATBOT_OPENROUTER_API_KEY", "")
from openai import OpenAI
client = OpenAI(api_key=KEY, base_url="https://openrouter.ai/api/v1")

models = [
    "google/gemma-4-26b-a4b-it:free",
    "google/gemma-4-31b-it:free",
    "nvidia/nemotron-3-super-120b-a12b:free",
    "nvidia/nemotron-3-nano-30b-a3b:free",
    "nvidia/nemotron-nano-9b-v2:free",
    "openai/gpt-oss-20b:free",
    "nvidia/nemotron-3-ultra-550b-a55b:free",
    "inclusionai/ling-3.0-tiny:free",
    "poolside/laguna-xs-2.1:free",
    "poolside/laguna-s-2.1:free",
]

print(f"Testing {len(models)} free models...\n")
working = []
for model in models:
    try:
        resp = client.chat.completions.create(
            model=model,
            messages=[{"role":"user","content":"Say OK"}],
            max_tokens=5, timeout=12,
        )
        text = resp.choices[0].message.content or ""
        print(f"✅ WORKS: {model}")
        working.append(model)
    except Exception as e:
        code = getattr(e, 'status_code', '?')
        msg = str(e)[:60]
        print(f"❌ [{code}] {model}: {msg}")

print(f"\n{len(working)}/{len(models)} models working right now.")
if working:
    print(f"\nBest model to use: {working[0]}")
