# Docker Usage

This document describes how to build and run the App::BlurFill web application
using Docker.

## Prerequisites

- Docker installed on your system
- Internet connection for downloading Perl dependencies during build

## Using the pre-built Docker image

The easiest way to run the App::BlurFill web app is to use the pre-built image
from Docker Hub:

```bash
docker run --rm -p 8080:3000 davorg/app-blurfill
```

Then open the app in your browser at:

http://localhost:8080/

The `-p` flag maps a port on your machine (here `8080`) to the port the app
listens on inside the container (`3000`).

If you prefer to use a different external port, just change the number before
the colon:

```bash
docker run --rm -p 5000:3000 davorg/app-blurfill
# now available at http://localhost:5000/
```

The image contains everything you need (Perl, dependencies, and the Dancer2
web app), so you don’t need a local Perl installation at all – just Docker.

## Building the Docker Image

### Manual Build

To build the Docker image manually, run the following command from the root of the repository:

```bash
docker build -t app-blurfill .
```

**Note**: The build process downloads Perl modules from CPAN, which requires internet access.

### Automated Build Script

The repository includes an automated build script at `docker/build` that handles version tagging and Git operations:

```bash
# Build from a specific version tag (RELEASE_x.x.x format)
./docker/build RELEASE_1.0.0

# Or use semver format (automatically looks for RELEASE_x.x.x tag)
./docker/build 1.0.0

# Or build from the highest available RELEASE tag
./docker/build
```

The build script:
- Validates that the specified version tag exists in the repository
- Stashes any uncommitted changes
- Checks out the specified tag
- Builds the Docker image with appropriate version tags
- Restores the original branch and uncommitted changes
- Pushes the built images to Docker Hub (if build succeeds)

**Requirements**:
- Git repository with RELEASE_x.x.x tags
- Docker credentials configured for pushing to davorg/app-blurfill

## Running the Container

Once the image is built, you can run the web application with:

```bash
docker run -p 3000:3000 app-blurfill
```

The web application will be available at http://localhost:3000

## Environment Variables

The application runs on port 3000 by default. You can change the port mapping by modifying the `-p` option:

```bash
docker run -p 8080:3000 app-blurfill
```

This will make the application available at http://localhost:8080

## Docker Compose (Optional)

You can also create a `docker-compose.yml` file for easier management:

```yaml
version: '3.8'
services:
  app-blurfill:
    build: .
    ports:
      - "3000:3000"
    restart: unless-stopped
```

Then run:

```bash
docker-compose up
```

## Technical Details

- **Base Image**: `perl:5.40-slim`
- **System Dependencies**: Image processing libraries (libgif, libjpeg, libpng, libtiff, libfreetype)
- **Perl Dependencies**: Installed via cpanm from Makefile.PL (Imager, Dancer2, Plack, Starman, etc.)
- **Web Server**: Starman (high-performance preforking Perl PSGI web server)
- **Port**: 3000 (default Dancer2 port)

## Troubleshooting

If the build fails during dependency installation, ensure:
1. You have internet connectivity
2. CPAN mirrors are accessible from your network
3. Docker has network access (check firewall/proxy settings)

### Debugging CPAN Build Failures

If you encounter build failures during the `cpanm --notest --installdeps .` step, you can use the debug Dockerfile to capture build logs:

```bash
docker build -f Dockerfile.debug -t app-blurfill-debug .
```

This will attempt to build the image and copy any cpanm build logs to `/app/cpanm-logs/` within the container. Even if the build fails, you can extract the logs:

```bash
# Create a container from the failed build (if it got far enough)
CONTAINER_ID=$(docker create app-blurfill-debug:latest 2>/dev/null || echo "Build did not complete")

# If a container was created, extract the logs
if [ "$CONTAINER_ID" != "Build did not complete" ]; then
  docker cp $CONTAINER_ID:/app/cpanm-logs/. ./build-logs/
  docker rm $CONTAINER_ID
  echo "Logs extracted to ./build-logs/"
fi
```

#### CI/CD Artifact Collection

When the Docker build fails in the GitHub Actions workflow (`.github/workflows/docker-publish.yml`), the workflow automatically:
1. Builds a debug image to capture logs
2. Extracts the cpanm build logs
3. Uploads them as GitHub Actions artifacts

You can download these artifacts from the failed workflow run in the GitHub Actions UI to diagnose the issue.
