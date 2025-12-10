# Complete Testing Guide Before GitHub Push

## Overview

This guide will walk you through testing your Docker setup completely before pushing to GitHub. Follow these steps in order.

---

## Prerequisites Check

Before you begin, ensure Docker Desktop is running:

```bash
# Check Docker is running
docker --version
docker ps
```

Expected output: Docker version information and list of running containers (may be empty).

---

## Phase 1: Local Build and Test

### Step 1: Clean Your Environment

Start fresh to ensure reproducibility:

```bash
cd "/Users/zhongyuli/Desktop/Softwares/R codes/CGM_ex1"

# Clean any previous outputs
make clean

# Remove any existing Docker images for your project
docker rmi zli577/cgm-report:latest 2>/dev/null || true

# Clean Docker cache (optional, if you want a completely fresh build)
# docker system prune -a  # WARNING: removes all unused images
```

### Step 2: Build the Docker Image

```bash
make docker-build
```

**What to look for:**
- ✅ Each step should complete without errors
- ✅ You'll see "Successfully built [image-id]"
- ✅ You'll see "Successfully tagged zli577/cgm-report:latest"

**Expected time:** 5-15 minutes (first build)

**Common issues:**
- "Cannot connect to Docker daemon" → Start Docker Desktop
- "No space left on device" → Run `docker system prune -a`

### Step 3: Verify the Image Exists

```bash
docker images | grep zli577/cgm-report
```

**Expected output:**
```
zli577/cgm-report   latest   [image-id]   [time]   [size]
```

### Step 4: Test Local Execution

```bash
# Ensure report directory is clean
rm -rf report/*

# Run the container
make docker-run
```

**What to look for:**
- ✅ "Running Docker container to generate report..."
- ✅ "Generating CGM figures with R..."
- ✅ "Rendering R Markdown report..."
- ✅ No error messages

**Expected time:** 2-5 minutes

### Step 5: Verify Outputs

```bash
# List generated files
ls -lh report/

# Count PNG files (should be 7)
ls report/*.png | wc -l

# Check HTML file exists
test -f report/participants.html && echo "✅ HTML report exists" || echo "❌ HTML missing"
```

**Expected files in `report/`:**
```
.gitkeep
participants.html
1007.png
1014.png
1024.png
1052.png
1055.png
1062.png
1066.png
```

### Step 6: Inspect the Report

```bash
# Open the HTML report (macOS)
open report/participants.html

# Or view file size to ensure it's not empty
ls -lh report/participants.html
```

**What to check:**
- ✅ HTML file opens in browser
- ✅ Tables are populated with data
- ✅ Figures are embedded or referenced
- ✅ No error messages in the report
- ✅ File size is reasonable (>50KB typically)

---

## Phase 2: DockerHub Push and Remote Test

### Step 7: Login to DockerHub

```bash
docker login
```

**Enter:**
- Username: `zli577`
- Password: [your DockerHub password]

**Expected output:** "Login Succeeded"

### Step 8: Push to DockerHub

```bash
docker push zli577/cgm-report:latest
```

**What to look for:**
- ✅ Multiple layers being pushed
- ✅ Progress bars for each layer
- ✅ "latest: digest: sha256:..." at the end
- ✅ No "unauthorized" or "denied" errors

**Expected time:** 2-10 minutes depending on upload speed

**Troubleshooting:**
- "unauthorized" → Check you're logged in with correct username
- "denied" → Repository might be private or name mismatch

### Step 9: Verify on DockerHub Website

1. Open browser and go to: https://hub.docker.com/
2. Log in with `zli577`
3. Navigate to: https://hub.docker.com/r/zli577/cgm-report
4. You should see:
   - ✅ Repository exists
   - ✅ "latest" tag is present
   - ✅ Recent push time
   - ✅ Image size displayed

### Step 10: Make Repository Public

**CRITICAL STEP** - Your instructor cannot pull private images!

1. On DockerHub, go to your repository page
2. Click "Settings" tab
3. Scroll to "Repository visibility"
4. Select "Public"
5. Click "Make public"
6. Confirm the action

**Verify:** Refresh the page and you should see a "Public" badge

### Step 11: Test Remote Pull (Simulate Fresh Environment)

This simulates what your instructor will experience:

```bash
# Remove local image completely
docker rmi zli577/cgm-report:latest

# Verify it's gone
docker images | grep zli577/cgm-report
# (should return nothing)

# Clean report directory
rm -rf report/*

# Now pull and run from DockerHub
make docker-run
```

**What to look for:**
- ✅ "Unable to find image 'zli577/cgm-report:latest' locally"
- ✅ "latest: Pulling from zli577/cgm-report"
- ✅ Download progress bars
- ✅ "Status: Downloaded newer image..."
- ✅ Report generation completes successfully
- ✅ Files appear in `report/` directory

**This is the MOST IMPORTANT test** - if this works, your instructor can run it!

---

## Phase 3: GitHub Preparation

### Step 12: Check Git Status

```bash
# See what's changed
git status
```

**Expected new/modified files:**
- `.dockerignore`
- `Dockerfile`
- `Makefile`
- `README.md`
- `.gitignore`
- `report/.gitkeep`
- `DOCKER_SETUP_GUIDE.md`
- `QUICK_START.md`
- `SUBMISSION_CHECKLIST.md`
- `PRE_SUBMISSION_TESTING.md` (this file)

### Step 13: Review Changes Before Commit

```bash
# Review changes to key files
git diff Makefile
git diff README.md
git diff Dockerfile
```

**Verify:**
- ✅ All references say `zli577/cgm-report:latest`
- ✅ DockerHub link is `https://hub.docker.com/r/zli577/cgm-report`
- ✅ No placeholder text like "YOUR_USERNAME"

### Step 14: Test .gitignore is Working

```bash
# These should NOT appear in git status:
git status | grep "report/participants.html"  # Should find nothing
git status | grep "report/.*\.png"            # Should find nothing
git status | grep "outputs/.*\.png"           # Should find nothing

# But .gitkeep SHOULD be tracked:
git status | grep "report/.gitkeep"           # Should show it
```

### Step 15: Stage All Changes

```bash
git add -A
```

### Step 16: Review What Will Be Committed

```bash
git status

# Double-check no sensitive or generated files
git diff --cached --name-only
```

**Should NOT include:**
- ❌ `report/*.png`
- ❌ `report/*.html`
- ❌ `outputs/*.png`
- ❌ `.Rhistory`, `.RData`
- ❌ Large data files (unless intentional)

**Should include:**
- ✅ `Dockerfile`
- ✅ `.dockerignore`
- ✅ `Makefile`
- ✅ `README.md`
- ✅ `report/.gitkeep`
- ✅ All guide files (.md)

---

## Phase 4: Final Validation

### Step 17: Run Complete Test Suite

```bash
# Test 1: Dockerfile exists
test -f Dockerfile && echo "✅ Dockerfile exists" || echo "❌ FAIL"

# Test 2: Can build image
docker build -t zli577/cgm-report:latest . > /dev/null 2>&1 && echo "✅ Build works" || echo "❌ FAIL"

# Test 3: Image exists locally
docker images zli577/cgm-report:latest | grep -q latest && echo "✅ Image tagged" || echo "❌ FAIL"

# Test 4: Can pull from DockerHub
docker pull zli577/cgm-report:latest > /dev/null 2>&1 && echo "✅ Pull works" || echo "❌ FAIL"

# Test 5: Can run and generate report
make docker-run > /dev/null 2>&1 && echo "✅ Run works" || echo "❌ FAIL"

# Test 6: Report generated
test -f report/participants.html && echo "✅ HTML created" || echo "❌ FAIL"

# Test 7: Figures generated
[ $(ls report/*.png 2>/dev/null | wc -l) -ge 5 ] && echo "✅ PNGs created" || echo "❌ FAIL"

# Test 8: README has DockerHub link
grep -q "zli577/cgm-report" README.md && echo "✅ README updated" || echo "❌ FAIL"

# Test 9: Makefile has correct image name
grep -q "zli577/cgm-report" Makefile && echo "✅ Makefile updated" || echo "❌ FAIL"
```

**All tests should show ✅** - if any show ❌, investigate before proceeding.

### Step 18: Test from Fresh Clone (Optional but Recommended)

This is the ultimate test:

```bash
# Go to a different directory
cd /tmp

# Clone your repo
git clone https://github.com/ZhLi7/data500_CGM.git test-clone
cd test-clone

# Run without building (should pull from DockerHub)
make docker-run

# Verify
ls -lh report/
```

**If this works, you're 100% ready!**

---

## Phase 5: Push to GitHub

### Step 19: Commit Your Changes

```bash
cd "/Users/zhongyuli/Desktop/Softwares/R codes/CGM_ex1"

git commit -m "Add Docker support for reproducible report generation

- Add Dockerfile with rocker/verse base image
- Add .dockerignore to exclude unnecessary files
- Update Makefile with docker-build and docker-run targets
- Update README with Docker instructions and DockerHub link
- Add comprehensive documentation (guides and checklists)
- Configure report/ directory structure with .gitkeep
- Update .gitignore to properly handle generated outputs

Docker image: zli577/cgm-report:latest
DockerHub: https://hub.docker.com/r/zli577/cgm-report"
```

### Step 20: Push to GitHub

```bash
git push origin main
```

**Expected output:**
- ✅ All files uploaded
- ✅ No errors
- ✅ "main -> main" confirmation

### Step 21: Verify on GitHub

1. Go to: https://github.com/ZhLi7/data500_CGM
2. Check that:
   - ✅ Dockerfile is visible
   - ✅ README.md updated (view it on GitHub)
   - ✅ Makefile updated
   - ✅ All guide files are present
   - ✅ `report/` directory exists with only `.gitkeep`

---

## Final Checklist

Before you consider this done, check ALL of these:

- [ ] ✅ Docker image builds successfully locally
- [ ] ✅ Docker image runs and generates report locally
- [ ] ✅ Docker image pushed to DockerHub
- [ ] ✅ DockerHub repository is PUBLIC
- [ ] ✅ Can pull image from DockerHub after deleting local copy
- [ ] ✅ `make docker-run` works with pulled image
- [ ] ✅ Report and figures generate correctly
- [ ] ✅ All files committed to git
- [ ] ✅ Git pushed to GitHub
- [ ] ✅ README.md reflects correct DockerHub username (zli577)
- [ ] ✅ Makefile uses correct image name (zli577/cgm-report:latest)
- [ ] ✅ No placeholder text (YOUR_USERNAME, etc.) in any files
- [ ] ✅ .gitignore properly excludes generated outputs
- [ ] ✅ report/ directory structure maintained

---

## What Your Instructor Will Do

They will:

1. Clone your GitHub repo
2. Run: `make docker-run`
3. Check: `report/participants.html`

That's it! No other steps.

**If you completed all tests above, this will work perfectly!**

---

## Quick Recovery Commands

If something goes wrong:

```bash
# Start over with Docker
docker system prune -a
make docker-build

# Start over with git (undo commit, not pushed yet)
git reset --soft HEAD~1

# Clean outputs and retry
make clean
rm -rf report/*
make docker-run

# Re-pull from DockerHub
docker rmi zli577/cgm-report:latest
docker pull zli577/cgm-report:latest

# Force push to DockerHub (if updated)
docker push zli577/cgm-report:latest
```

---

## Success Indicators

You know you're done when:

1. ✅ Running `docker rmi zli577/cgm-report:latest && make docker-run` successfully downloads from DockerHub and generates the report
2. ✅ GitHub shows all your Docker-related files
3. ✅ DockerHub page shows "Public" badge and recent push
4. ✅ README.md clearly explains how to run with Docker
5. ✅ All documentation files are present and updated

---

## Estimated Time

- Phase 1 (Local Build/Test): 15-20 minutes
- Phase 2 (DockerHub): 10-15 minutes
- Phase 3 (GitHub Prep): 5-10 minutes
- Phase 4 (Validation): 10-15 minutes
- Phase 5 (Push): 5 minutes

**Total: 45-65 minutes** for thorough testing

---

## Need Help?

If any test fails:

1. Check the specific error message
2. Refer to `DOCKER_SETUP_GUIDE.md` troubleshooting section
3. Ensure Docker Desktop is running
4. Verify internet connection (for DockerHub operations)
5. Check DockerHub repository is truly PUBLIC

**Good luck! You've got this!** 🚀
