# Docker Setup Guide for Final Submission

## Prerequisites

1. Install Docker Desktop:
   - Mac: https://docs.docker.com/desktop/install/mac-install/
   - Windows: https://docs.docker.com/desktop/install/windows-install/
   - Linux: https://docs.docker.com/desktop/install/linux-install/

2. Create a DockerHub account (if you don't have one):
   - Go to https://hub.docker.com/
   - Sign up for a free account

## Step-by-Step Instructions

### 1. Build the Docker Image Locally

From your project root directory:

```bash
# Option A: Use the Makefile
make docker-build

# Option B: Use docker command directly
docker build -t zli577/cgm-report:latest .
```

This will:
- Use the base image `rocker/verse:4.5.1` (includes R, RStudio, tidyverse, RMarkdown)
- Install system dependencies
- Copy your project files
- Restore R packages from `renv.lock`
- Create a reproducible R environment

**Expected time:** 5-15 minutes on first build (depending on internet speed)

### 2. Test the Image Locally

Before pushing to DockerHub, verify it works:

```bash
# Mac/Linux:
make docker-run

# Windows:
make docker-run-windows
```

Check that the `report/` directory now contains:
- `participants.html` — Your rendered report
- Multiple `.png` files — CGM figures

If this works, you're ready to push to DockerHub!

### 3. Push to DockerHub

#### Login to DockerHub

```bash
docker login
```

Enter your DockerHub username and password when prompted.

#### Tag the Image (if needed)

If you used a different tag or want to ensure correct naming:

```bash
# This should already be correct if you used the commands above
docker tag zli577/cgm-report:latest zli577/cgm-report:latest
```

#### Push to DockerHub

```bash
docker push zli577/cgm-report:latest
```

**Expected time:** 2-10 minutes depending on upload speed

#### Verify on DockerHub

1. Go to https://hub.docker.com/
2. Log in to your account
3. Click on "Repositories"
4. You should see `cgm-report` listed
5. Click on it to view details

### 4. Make the Repository Public

By default, new repositories might be private. To make it public:

1. On DockerHub, go to your `cgm-report` repository
2. Click on "Settings"
3. Scroll to "Repository visibility"
4. Select "Public"
5. Click "Save"

### 5. Update README with Your DockerHub Link

The README has been updated to use `zli577` as the DockerHub username. Verify these lines:

```markdown
**[zli577/cgm-report:latest](https://hub.docker.com/r/zli577/cgm-report)**
```

And in the Makefile, the docker-run targets use `zli577/cgm-report:latest`.

### 6. Test from DockerHub (Simulate Fresh Environment)

### 6. Test from DockerHub (Simulate Fresh Environment)

After pushing to DockerHub, test the complete workflow:

```bash
docker rmi zli577/cgm-report:latest
```

### Run from DockerHub

```bash
# Mac/Linux:
make docker-run

# Windows:
make docker-run-windows
```

This should:
1. Automatically pull the image from DockerHub
2. Run the container
3. Generate the report in the `report/` directory

**If this works, your submission is ready!** ✅

## Troubleshooting

### Issue: "permission denied while trying to connect to Docker daemon"

**Mac/Linux:**
```bash
sudo docker login
sudo make docker-build
sudo docker push zli577/cgm-report:latest
```

Or add your user to the docker group:
```bash
sudo usermod -aG docker $USER
# Log out and back in
```

### Issue: "renv restore fails"

This might happen if packages aren't available. The Dockerfile already handles this, but if you need to update:

```bash
# Locally, update renv.lock
Rscript -e "renv::snapshot()"
# Then rebuild the image
```

### Issue: "Docker build runs out of space"

Clean up old images:
```bash
docker system prune -a
```

### Issue: Windows path issues

Make sure you're using the correct Makefile target:
```bash
# Use this on Windows:
make docker-run-windows

# NOT this:
make docker-run
```

## Summary Checklist for Submission

- [ ] Dockerfile exists in repository root
- [ ] .dockerignore exists and excludes unnecessary files
- [ ] Makefile has `docker-run` target with no prerequisites
- [ ] README.md includes:
  - [ ] Instructions for building the image
  - [ ] Link to DockerHub repository
  - [ ] Instructions for running the automated version
  - [ ] Platform-specific notes (Mac/Linux vs Windows)
- [ ] Docker image is pushed to DockerHub
- [ ] DockerHub repository is PUBLIC
- [ ] `report/` directory exists with `.gitkeep`
- [ ] `.gitignore` configured to ignore report outputs but track structure
- [ ] Tested `make docker-run` successfully generates report

## Quick Reference Commands

```bash
# Build image
make docker-build

# Test locally (Mac/Linux)
make docker-run

# Test locally (Windows)
make docker-run-windows

# Push to DockerHub
docker login
docker push zli577/cgm-report:latest

# Clean up
make clean
docker system prune -a
```

## Expected Deliverables Location

After running `make docker-run`, find your outputs in:
```
report/
├── .gitkeep
├── participants.html     # Main report
├── 1007.png             # CGM figure for participant 1007
├── 1014.png             # CGM figure for participant 1014
├── 1024.png             # ... and more
└── ... more PNG files
```

## Notes

- The Docker container runs in an isolated environment
- Only the `report/` directory is written to your local filesystem
- The `data/` directory is mounted read-only to prevent accidental modifications
- Container automatically cleans up after completion (--rm flag)
