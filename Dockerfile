# Stage 1: Base Image
FROM python:3.9 AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on

# Install dependencies
RUN pip install --upgrade pip

# Stage 2: Build Dependencies
FROM base AS build-dependencies

# Create and set the working directory
WORKDIR /build

# Copy only the requirements file initially to leverage caching
COPY requirements.txt .

# Install dependencies with caching
RUN pip install --prefix="/install" -r requirements.txt

# Stage 3: Application Build
FROM base AS application-build

# Set the working directory inside the container
WORKDIR /app

# Copy only necessary files from the build-dependencies stage
COPY --from=build-dependencies /install /usr/local

# Copy the rest of the application code
COPY . .

# Perform additional build steps if needed
# For example, if you have a frontend build process

# Stage 4: Production
FROM base AS production

# Set the working directory inside the container
WORKDIR /app

# Copy only necessary files from the application-build stage
COPY --from=application-build /usr/local /usr/local

# Set environment variables
ENV FLASK_APP=app.py \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5000 \
    FLASK_ENV=production

# Expose the application port
EXPOSE $FLASK_RUN_PORT

# Command to run the application
CMD ["flask", "run"]
