# icon_rearranger.py

import json
from sentence_transformers import SentenceTransformer, util

# Load model once
model = SentenceTransformer("all-MiniLM-L6-v2")

# Load icons
with open("../flutter_app/assets/icon_categories.json", "r") as f:
    icon_data = json.load(f)

icon_items = []
icon_words = []
for cat in icon_data:
    for item in cat["items"]:
        icon_items.append({
            "word": item["word"].lower(),
            "image": item["image"],
            "category": cat["category"]
        })
        icon_words.append(item["word"].lower())

icon_embeddings = model.encode(icon_words, convert_to_tensor=True)

def get_icon_by_words(words):
    matched = []
    for word in words:
        for icon in icon_items:
            if icon["word"] == word.lower():
                matched.append(icon)
                break
    return matched

def get_best_matching_icons(sentence, top_k=8):
    query_emb = model.encode(sentence, convert_to_tensor=True)
    cos_scores = util.pytorch_cos_sim(query_emb, icon_embeddings)[0]
    top_results = cos_scores.topk(top_k)

    return [icon_items[i] for i in top_results.indices]
