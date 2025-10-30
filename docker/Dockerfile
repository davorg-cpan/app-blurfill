# Use official Perl base image
FROM perl:5.40-slim

# Install system dependencies for Imager module
# Imager needs image processing libraries
RUN apt-get update && apt-get install -y \
    libgif-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libfreetype6-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy application files
COPY . .

# Install Perl dependencies
# Based on PREREQ_PM in Makefile.PL
RUN cpanm --notest --installdeps .

# Expose port 8080 (default Dancer2/Plack port)
EXPOSE 8080

# Run the PSGI application with plackup and Starman server
CMD sh -lc 'exec plackup -I lib -s Starman -a bin/app.psgi -o 0.0.0.0 -p ${PORT:-8080}'
