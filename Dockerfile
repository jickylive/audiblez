# Use official Python 3.11 slim image
FROM python:3.11-slim

# Set environment variables
# HF_HOME: Caches HuggingFace models under /root/.cache/huggingface
# PYTHONUNBUFFERED: Prevents Python from buffering stdout/stderr
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HF_HOME=/root/.cache/huggingface \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

# Install system dependencies
# ffmpeg: required to compile audiobooks into .m4b
# espeak-ng / libespeak-ng-dev: required by phonemizer for TTS grapheme-to-phoneme conversion
# libsndfile1: required by soundfile python package
# git: required for dependency resolution / installing git-based packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    espeak-ng \
    libespeak-ng-dev \
    libsndfile1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory for app installation
WORKDIR /app

# Install poetry to ensure exact dependencies from poetry.lock are installed
RUN pip install --no-cache-dir poetry

# Copy dependency files first to leverage Docker cache
COPY pyproject.toml poetry.lock /app/

# Create a dummy source package structure so poetry install --no-root can resolve correctly
RUN mkdir -p /app/audiblez && touch /app/audiblez/__init__.py

# Install python dependencies defined in poetry.lock
RUN poetry lock
RUN poetry install --no-root --no-ansi

# Copy the model downloading script
COPY download_models.py /app/

# Download and cache Spacy and Kokoro models inside the image during build
RUN python download_models.py

# Copy the actual source files (overwriting the dummy file)
COPY . /app/

# Install the actual package along with its entrypoint CLI scripts
RUN pip install --no-cache-dir .

# Create and switch to directory for runtime mounted books and output files
WORKDIR /data

# Set entrypoint to the audiblez command-line interface
ENTRYPOINT ["audiblez"]

# Default to printing the CLI help menu
CMD ["--help"]
