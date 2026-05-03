FROM python:3.11-slim

# Install Node.js, curl, and build tools
RUN apt-get update && apt-get install -y curl build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install uv (Python package manager used in backend)
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR=/usr/local/bin bash

WORKDIR /app

# Copy package configurations first to leverage Docker cache
COPY package.json package-lock.json* ./
COPY frontend/package.json frontend/package-lock.json* ./frontend/
COPY backend/pyproject.toml backend/uv.lock ./backend/

# Setup both Node.js and Python dependencies
RUN npm run setup:all

# Copy the rest of the application source code
COPY . .

# Expose Vite frontend (3000) and Flask backend (5001) ports
EXPOSE 3000 5001

# Command to run both concurrently
CMD ["npm", "run", "dev"]


