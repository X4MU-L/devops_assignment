# Build stage
FROM python:3.13-slim AS builder
ENV PYTHONUNBUFFERED=1 
ENV VENV_PATH="/opt/venv"

# Create a virtual environment in a custom path
RUN python -m venv $VENV_PATH

# Ensure pip is up to date inside the venv
RUN $VENV_PATH/bin/pip install --upgrade pip

# Set PATH to use venv by default
ENV PATH="$VENV_PATH/bin:$PATH"

WORKDIR /app

# Install dependencies first for caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# ---------- TEST STAGE ----------
FROM builder AS test
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir pytest pytest-mock flask-testing
ENV ENV=test
CMD ["pytest", "tests/"]

# ---------- DEV STAGE ----------
FROM python:3.13-slim AS dev
WORKDIR /app

# Copy only requirements first for cache-friendly builds
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir debugpy
RUN apt-get update && apt-get install -y curl

# Then copy the rest of the app
COPY . .

ENV ENV=dev
ENV PYTHONUNBUFFERED=1
EXPOSE 5678
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "main.py"]

# ---------- STAGING STAGE ----------
FROM python:alpine AS staging
ENV PYTHONUNBUFFERED=1 
ENV VENV_PATH="/opt/venv"
ENV ENV=staging

# Copy virtual environment and app
COPY --from=builder $VENV_PATH $VENV_PATH
COPY --from=builder /app /app
RUN apt-get update && apt-get install -y curl

# Activate the virtual environment
ENV PATH="$VENV_PATH/bin:$PATH"
USER 1000

WORKDIR /app
CMD ["python", "main.py"]

# ---------- PRODUCTION STAGE ----------


# Production stage
FROM python:alpine AS prod
ENV PYTHONUNBUFFERED=1 
ENV VENV_PATH="/opt/venv"
ENV ENV=prod

# Copy virtual environment and app
COPY --from=builder $VENV_PATH $VENV_PATH
COPY --from=builder /app /app
RUN apt-get update && apt-get install -y curl
# Activate the virtual environment
ENV PATH="$VENV_PATH/bin:$PATH"
USER 1000

WORKDIR /app
CMD ["python", "main.py"]