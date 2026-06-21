#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import spacy
from kokoro import KPipeline

def download_all():
    print("=== Downloading Spacy xx_ent_wiki_sm model ===")
    try:
        if not spacy.util.is_package("xx_ent_wiki_sm"):
            spacy.cli.download("xx_ent_wiki_sm")
        print("Spacy model downloaded successfully.")
    except Exception as e:
        print(f"Error downloading Spacy model: {e}")

    print("\n=== Downloading Kokoro models and voices ===")
    # Kokoro supports: 'a' (US English), 'b' (UK English), 'e' (Spanish), 'f' (French),
    # 'h' (Hindi), 'i' (Italian), 'j' (Japanese), 'p' (Brazilian Portuguese), 'z' (Mandarin Chinese)
    languages = ['a', 'b', 'e', 'f', 'h', 'i', 'j', 'p', 'z']
    for lang in languages:
        try:
            print(f"Pre-caching pipeline for language code: '{lang}'...")
            # Instantiating KPipeline downloads the model weights and default voice files
            KPipeline(lang_code=lang)
            print(f"Pipeline for '{lang}' cached successfully.")
        except Exception as e:
            print(f"Warning: Failed to pre-cache pipeline for '{lang}': {e}")
            print("It will be downloaded at runtime if needed.")

    print("\n=== Model downloading and caching finished ===")

if __name__ == '__main__':
    download_all()
