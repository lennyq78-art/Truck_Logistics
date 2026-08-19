FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Prevent Python from writing .pyc files & enable unbuffered stdout/stderr logging
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY . .

# Run database seed script
RUN python seed.py

# Expose port
EXPOSE 8000

# Start Uvicorn server dynamically binding to $PORT assigned by cloud provider
CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}
