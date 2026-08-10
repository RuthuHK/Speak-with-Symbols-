# Install required libraries if not already installed:
# pip install transformers datasets accelerate scikit-learn
'''
from transformers import (
    T5Tokenizer,
    T5ForConditionalGeneration,
    Seq2SeqTrainer,
    Seq2SeqTrainingArguments,
    DataCollatorForSeq2Seq,
    EarlyStoppingCallback,
)
from datasets import Dataset
import json
import torch
import random
from sklearn.model_selection import train_test_split

# Load and shuffle your dataset
with open("suggestions_dataset.jsonl", "r", encoding="utf-8") as f:
    data = [json.loads(line.strip()) for line in f if line.strip()]

random.shuffle(data)

# Split into train/val for better generalization
train_data, val_data = train_test_split(data, test_size=0.1, random_state=42)
train_dataset = Dataset.from_list(train_data)
val_dataset = Dataset.from_list(val_data)

# Load model and tokenizer
model_name = "t5-small"
tokenizer = T5Tokenizer.from_pretrained(model_name)
model = T5ForConditionalGeneration.from_pretrained(model_name)

# Preprocess function with label cleanup and correct padding
def preprocess(example):
    input_text = example["input"].strip()
    target_text = example["target"].strip().lower()

    model_input = tokenizer(
        input_text,
        padding="max_length",
        truncation=True,
        max_length=32,
        return_tensors="pt"
    )
    with tokenizer.as_target_tokenizer():
        labels = tokenizer(
            target_text,
            padding="max_length",
            truncation=True,
            max_length=32,
            return_tensors="pt"
        )
    labels["input_ids"] = [
        (token if token != tokenizer.pad_token_id else -100)
        for token in labels["input_ids"][0]
    ]
    model_input = {k: v[0] for k, v in model_input.items()}
    model_input["labels"] = torch.tensor(labels["input_ids"])
    return model_input

# Tokenize the datasets
tokenized_train = train_dataset.map(preprocess)
tokenized_val = val_dataset.map(preprocess)

# Set training arguments (add early stopping, eval, and save best)
training_args = Seq2SeqTrainingArguments(
    output_dir="./t5_suggestion_model",
    per_device_train_batch_size=4,
    per_device_eval_batch_size=4,
    num_train_epochs=20,
    logging_dir="./logs",
    logging_steps=10,
    save_strategy="epoch",
    eval_strategy="epoch",
    fp16=False,
    load_best_model_at_end=True,
    metric_for_best_model="eval_loss",
    greater_is_better=False,
    save_total_limit=2,
)

data_collator = DataCollatorForSeq2Seq(tokenizer, model=model)

# Trainer with validation and early stopping
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_val,
    tokenizer=tokenizer,
    data_collator=data_collator,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=3)],
)

trainer.train()

# Save model and tokenizer
trainer.save_model("./t5_suggestion_model")
tokenizer.save_pretrained("./t5_suggestion_model")

def generate_suggestions(prompt, num_return_sequences=5):
    input_ids = tokenizer(prompt, return_tensors="pt").input_ids
    outputs = model.generate(
        input_ids,
        max_length=32,
        num_return_sequences=num_return_sequences,
        do_sample=True,
        top_k=50,
        top_p=0.95,
        temperature=0.9,
        repetition_penalty=1.3,
        no_repeat_ngram_size=2,
        early_stopping=True,
    )
    # Post-process: split by comma, strip whitespace, deduplicate
    suggestions = []
    for o in outputs:
        decoded = tokenizer.decode(o, skip_special_tokens=True)
        # Split by comma, strip, and filter empty
        items = [s.strip() for s in decoded.split(',') if s.strip()]
        # Remove duplicates, preserve order
        seen = set()
        unique_items = [x for x in items if not (x in seen or seen.add(x))]
        suggestions.append(unique_items)
    return suggestions

# Example usage:
# print(generate_suggestions("suggest next: I want"))
'''

# Install required libraries if not already installed:
# pip install transformers datasets accelerate scikit-learn

from transformers import (
    T5Tokenizer,
    T5ForConditionalGeneration,
    Seq2SeqTrainer,
    Seq2SeqTrainingArguments,
    DataCollatorForSeq2Seq,
    EarlyStoppingCallback,
)
from datasets import Dataset
import json
import torch
import random
from sklearn.model_selection import train_test_split

# Load and shuffle your dataset
with open("new_train.jsonl", "r", encoding="utf-8") as f:
    data = [json.loads(line.strip()) for line in f if line.strip()]

random.shuffle(data)

# Split into train/val
train_data, val_data = train_test_split(data, test_size=0.1, random_state=42)
train_dataset = Dataset.from_list(train_data)
val_dataset = Dataset.from_list(val_data)

# Load model and tokenizer
model_name = "t5-small"
tokenizer = T5Tokenizer.from_pretrained(model_name)
model = T5ForConditionalGeneration.from_pretrained(model_name)

# Preprocess function
def preprocess(example):
    input_text = example["input"].strip()
    target_text = example["target"].strip().lower()

    model_input = tokenizer(
        input_text,
        padding="max_length",
        truncation=True,
        max_length=32,
        return_tensors="pt"
    )
    with tokenizer.as_target_tokenizer():
        labels = tokenizer(
            target_text,
            padding="max_length",
            truncation=True,
            max_length=32,
            return_tensors="pt"
        )
    labels["input_ids"] = [
        (token if token != tokenizer.pad_token_id else -100)
        for token in labels["input_ids"][0]
    ]
    model_input = {k: v[0] for k, v in model_input.items()}
    model_input["labels"] = torch.tensor(labels["input_ids"])
    return model_input

# Tokenize datasets
tokenized_train = train_dataset.map(preprocess)
tokenized_val = val_dataset.map(preprocess)

# Training arguments
training_args = Seq2SeqTrainingArguments(
    output_dir="./t5_suggestion_model",
    per_device_train_batch_size=4,
    per_device_eval_batch_size=4,
    num_train_epochs=5,
    logging_dir="./logs",
    logging_steps=10,
    save_strategy="epoch",
    eval_strategy="epoch",
    fp16=False,
    load_best_model_at_end=True,
    metric_for_best_model="eval_loss",
    greater_is_better=False,
    save_total_limit=2,
)

data_collator = DataCollatorForSeq2Seq(tokenizer, model=model)

# Trainer
trainer = Seq2SeqTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_train,
    eval_dataset=tokenized_val,
    tokenizer=tokenizer,
    data_collator=data_collator,
    callbacks=[EarlyStoppingCallback(early_stopping_patience=3)],
)

trainer.train()

# Save model/tokenizer
trainer.save_model("./t5_suggestion_model")
tokenizer.save_pretrained("./t5_suggestion_model")

# Load allowed words from JSON
with open("image_names.json", "r", encoding="utf-8") as f:
    raw_allowed_words = json.load(f)  # Expects a list like ["good_morning", "apple", ...]

# Normalize: replace underscores with spaces, lowercased
allowed_words = set(word.replace('_', ' ').lower() for word in raw_allowed_words)

# Suggestion generation with filtering
def generate_suggestions(prompt, num_return_sequences=5):
    input_ids = tokenizer(prompt, return_tensors="pt").input_ids
    outputs = model.generate(
        input_ids,
        max_length=32,
        num_return_sequences=num_return_sequences,
        do_sample=True,
        top_k=50,
        top_p=0.95,
        temperature=0.9,
        repetition_penalty=1.3,
        no_repeat_ngram_size=2,
        early_stopping=True,
    )
    suggestions = []
    for o in outputs:
        decoded = tokenizer.decode(o, skip_special_tokens=True)
        items = [s.strip().lower() for s in decoded.split(',') if s.strip()]
        # Filter against allowed words
        filtered = [word for word in items if word in allowed_words]
        # Deduplicate, preserve order
        seen = set()
        unique_items = [x for x in filtered if not (x in seen or seen.add(x))]
        suggestions.append(unique_items)
    return suggestions


# ✅ Example usage:
if __name__ == "__main__":
    prompt = "suggest next: I want"
    suggestions = generate_suggestions(prompt, num_return_sequences=5)
    print("Filtered Suggestions:")
    for idx, suggestion_set in enumerate(suggestions, 1):
        print(f"{idx}: {suggestion_set}")

