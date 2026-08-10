import json
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut

# Load SentenceTransformer model
model = SentenceTransformer('all-MiniLM-L6-v2')

# Load the dataset with precomputed embeddings
with open("embeddings.json", "r") as f:
    icons = json.load(f)

# Convert embeddings to NumPy array
icon_embeddings = np.array([icon['embedding'] for icon in icons])

# Robust reverse geocoding with retry logic
def get_location_name(lat, lon, retries=3):
    geolocator = Nominatim(user_agent="aac_location_app")
    for _ in range(retries):
        try:
            location = geolocator.reverse((lat, lon), exactly_one=True)
            return location.address if location else "Unknown"
        except GeocoderTimedOut:
            continue
    return "Unknown"

# Rule-based classification with expanded categories
def classify_location(place_name: str) -> str:
    place_name = place_name.lower()
    rules = {
        "educational": [
            "school", "college", "university", "academy", "institution", "campus", "training center", "tuition"
        ],
        "medical": [
            "hospital", "clinic", "medical", "health", "pharmacy", "dispensary", "diagnostic", "emergency", "nursing home"
        ],
        "home": [
            "home", "residence", "apartment", "house", "flat", "villa", "bungalow", "gated community", "hostel", "dorm"
        ],
        "shopping": [
            "mall", "store", "market", "shopping", "supermarket", "grocery", "bazaar", "outlet", "retail", "departmental"
        ],
        "religious": [
            "temple", "church", "mosque", "mandir", "masjid", "gurdwara", "synagogue", "shrine", "cathedral", "ashram"
        ],
        "transport": [
            "airport", "station", "bus stop", "railway", "metro", "bus terminal", "train station", "auto stand", "cab stand"
        ],
        "restaurant": [
            "restaurant", "cafe", "food court", "eatery", "canteen", "diner", "bistro", "coffee shop", "bar", "fast food"
        ],
        "bank": [
            "bank", "atm", "branch", "credit union"
        ],
        "office": [
            "office", "it park", "tech park", "corporate", "company", "firm", "workspace", "co-working", "business center"
        ],
        "recreation": [
            "park", "playground", "zoo", "amusement", "theme park", "garden", "lake", "resort", "beach", "museum", "aquarium"
        ],
        "government": [
            "police station", "post office", "court", "municipal", "corporation", "govt office", "embassy"
        ],
        "hotel": [
            "hotel", "lodge", "inn", "guest house", "bnb", "motel", "residency", "homestay"
        ],
        "sports": [
            "stadium", "sports complex", "gym", "fitness center", "yoga", "club", "arena", "court", "cricket", "football"
        ],
        "entertainment": [
            "cinema", "movie", "theatre", "concert", "auditorium", "hall", "event", "exhibition", "gallery"
        ],
        "industrial": [
            "factory", "plant", "warehouse", "industrial", "manufacturing", "processing unit", "workshop"
        ],
        "general": [
            "community center", "hall", "center", "landmark", "intersection", "junction", "unknown"
        ]
    }

    for category, keywords in rules.items():
        if any(k in place_name for k in keywords):
            return category
    return "general"

# Get top N similar icons using cosine similarity
def get_similar_icons(context_text, top_n=10):
    context_emb = model.encode(context_text).reshape(1, -1)
    similarities = cosine_similarity(context_emb, icon_embeddings)[0]
    top_indices = similarities.argsort()[::-1][:top_n]
    return [icons[i] for i in top_indices]

# MAIN
if __name__ == "__main__":
    # Example location: PES University
    lat = 12.9341
    lon = 77.5352
    

    place = get_location_name(lat, lon)
    print(f"📍 Detected place: {place}")

    location_type = classify_location(place)
    print(f"🏷️  Classified as: {location_type}")

    similar_icons = get_similar_icons(location_type, top_n=10)
    print("\n🎯 Top relevant icons:")
    for icon in similar_icons:
       print(f"✅ {icon['name']}")
