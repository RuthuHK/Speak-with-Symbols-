# from flask import Flask, request, jsonify
# from transformers import BartTokenizer, BartForConditionalGeneration
# from googletrans import Translator
# from gtts import gTTS
# import os

# app = Flask(__name__)

# # Load the model and tokenizer once
# model = BartForConditionalGeneration.from_pretrained("./bart-aac-model")
# tokenizer = BartTokenizer.from_pretrained("./bart-aac-model")
# translator = Translator()

# @app.route('/generate', methods=['POST'])
# def generate_sentence():
#     data = request.get_json()
#     words = data.get("words", [])
#     input_text = " ".join(words)

#     # Step 1: BART Generation
#     inputs = tokenizer(input_text, return_tensors="pt")
#     output = model.generate(**inputs, max_length=32, num_beams=4)
#     generated = tokenizer.decode(output[0], skip_special_tokens=True)

#     # Step 2: Translations
#     translated_hi = translator.translate(generated, src='en', dest='hi').text
#     translated_kn = translator.translate(generated, src='en', dest='kn').text

#     # Step 3: Optionally save TTS (not required for frontend)
#     # tts = gTTS(text=generated, lang='en')
#     # tts.save("output_en.mp3")

#     return jsonify({
#         "sentence": generated,
#         "translation_hi": translated_hi,
#         "translation_kn": translated_kn
#     })

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)
#########################################################

# from flask import Flask, request, jsonify
# from flask_cors import CORS

# app = Flask(__name__)
# CORS(app)  # Allow all CORS

# @app.route('/generate', methods=['POST'])
# def generate():
#     data = request.get_json()

#     # Optional: for translation only
#     if data.get("translate_only"):
#         sentence = data.get("sentence")
#         lang = data.get("lang")
#         return jsonify({"translation": f"{sentence} (translated to {lang})"})

#     # Sentence generation (dummy)
#     words = data.get("words", [])
#     input_text = " ".join(words)
#     sentence = f"{input_text.capitalize()} is important."
#     return jsonify({"sentence": sentence})

# if __name__ == '__main__':
#     # Make sure to run on 0.0.0.0 to be accessible on the network
#     app.run(host='0.0.0.0', port=5000, debug=True)
####################################################

# from flask import Flask, request, jsonify
# from flask_cors import CORS
# from transformers import BartForConditionalGeneration, BartTokenizer
# import torch

# app = Flask(__name__)
# CORS(app)

# # Load the BART model and tokenizer once
# model_path = "./bart-aac-model"
# tokenizer = BartTokenizer.from_pretrained(model_path)
# model = BartForConditionalGeneration.from_pretrained(model_path)

# @app.route('/generate', methods=['POST'])
# def generate():
#     data = request.get_json()

#     if data.get("translate_only"):
#         sentence = data.get("sentence")
#         lang = data.get("lang")
#         return jsonify({"translation": f"{sentence} (translated to {lang})"})

#     words = data.get("words", [])
#     input_text = " ".join(words)

#     # Generate sentence using BART
#     inputs = tokenizer([input_text], return_tensors="pt", padding=True)
#     summary_ids = model.generate(
#         inputs["input_ids"],
#         max_length=50,
#         num_beams=4,
#         early_stopping=True
#     )
#     sentence = tokenizer.decode(summary_ids[0], skip_special_tokens=True)

#     print(f"🧠 Generated sentence: {sentence}")  # ✅ Debug log

#     return jsonify({"sentence": sentence})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)

##########################################

# from flask import Flask, request, jsonify
# from flask_cors import CORS
# from transformers import BartForConditionalGeneration, BartTokenizer
# from googletrans import Translator

# # Initialize app
# app = Flask(__name__)
# CORS(app)

# # Load BART model and tokenizer
# model_path = "./bart-aac-model"
# tokenizer = BartTokenizer.from_pretrained(model_path)
# model = BartForConditionalGeneration.from_pretrained(model_path)

# # Google Translate
# translator = Translator()

# @app.route('/generate', methods=['POST'])
# def generate():
#     data = request.get_json()

#     # If translation-only request
#     if data.get("translate_only"):
#         sentence = data.get("sentence", "")
#         lang = data.get("lang", "hi")

#         try:
#             translated_text = translator.translate(sentence, src="en", dest=lang).text
#             return jsonify({"translation": translated_text})
#         except Exception as e:
#             return jsonify({"error": str(e)}), 500

#     # Full generation request
#     words = data.get("words", [])
#     input_text = " ".join(words)

#     # Generate sentence using BART
#     inputs = tokenizer(input_text, return_tensors="pt")
#     outputs = model.generate(inputs["input_ids"], max_length=32, num_beams=4, early_stopping=True)
#     generated_sentence = tokenizer.decode(outputs[0], skip_special_tokens=True)

#     return jsonify({"sentence": generated_sentence})

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000, debug=True)


from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from transformers import BartForConditionalGeneration, BartTokenizer
from googletrans import Translator
from gtts import gTTS
import os
import uuid

import torch
device = torch.device("cpu")


app = Flask(__name__)
CORS(app)

# Load model and tokenizer
model_path = "./bart-aac-model"
tokenizer = BartTokenizer.from_pretrained(model_path)
model = BartForConditionalGeneration.from_pretrained(model_path).to(device)

# Initialize Google Translator
translator = Translator()

# === Helper Function to Generate TTS ===
def generate_tts(text, lang):
    try:
        filename = f"tts_{uuid.uuid4().hex}.mp3"
        tts = gTTS(text=text, lang=lang)
        tts.save(filename)
        return filename
    except Exception as e:
        print(f"TTS generation error: {e}")
        return None

# === Route: Generate Sentence or Translate ===
@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()

    # 🔁 Translate only
    if data.get("translate_only"):
        sentence = data.get("sentence", "")
        lang = data.get("lang", "hi")

        try:
            translated_text = translator.translate(sentence, src="en", dest=lang).text

            # Generate TTS
            tts_file = generate_tts(translated_text, lang)
            if not tts_file:
                return jsonify({"error": "TTS generation failed"}), 500

            return jsonify({
                "translation": translated_text,
                "tts_url": f"/tts/{tts_file}"
            })

        except Exception as e:
            return jsonify({"error": str(e)}), 500

    # 🧠 Sentence generation
    words = data.get("words", [])
    input_text = " ".join(words)

    inputs = tokenizer(input_text, return_tensors="pt")
    try:
        input_ids = inputs["input_ids"].to(device)
        with torch.no_grad():
            outputs = model.generate(input_ids, max_length=32, num_beams=4, early_stopping=True)
        sentence = tokenizer.decode(outputs[0], skip_special_tokens=True)
    except Exception as e:
        print(f"Model inference error: {e}")
        sentence = "Sorry, there was an error processing your request."



    # Generate English TTS
    tts_file = generate_tts(sentence, 'en')

    return jsonify({
        "sentence": sentence,
        "tts_url": f"/tts/{tts_file}" if tts_file else None
    })

# === Route: Serve MP3 Files ===
@app.route('/tts/<filename>')
def serve_tts(filename):
    path = os.path.join(os.getcwd(), filename)
    if os.path.exists(path):
        return send_file(path, mimetype="audio/mpeg")
    return "File not found", 404

# code to rearrange icons in response to speaker
from icon_rearranger import get_best_matching_icons

@app.route("/rearrange_icons", methods=["POST"])
def rearrange_icons():
    data = request.get_json()
    sentence = data.get("sentence", "")
    if not sentence:
        return jsonify({"error": "No sentence provided"}), 400

    try:
        icons = get_best_matching_icons(sentence)
        return jsonify({"icons": icons})
    except Exception as e:
        return jsonify({"error": str(e)}), 500



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
