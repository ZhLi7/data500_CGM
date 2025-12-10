#!/bin/bash
# Quick Testing Script for Docker Setup
# Run this before pushing to GitHub

set -e  # Exit on error

echo "=========================================="
echo "Docker Setup Testing Script"
echo "Project: CGM Report Generator"
echo "Docker Image: zli577/cgm-report:latest"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_TOTAL=0

# Test function
test_step() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -n "Test $TESTS_TOTAL: $1 ... "
}

pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✅ PASS${NC}"
}

fail() {
    echo -e "${RED}❌ FAIL${NC}"
    echo "   Error: $1"
}

warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}"
    echo "   Warning: $1"
}

echo "Phase 1: File Existence Checks"
echo "-----------------------------------"

test_step "Dockerfile exists"
if [ -f "Dockerfile" ]; then
    pass
else
    fail "Dockerfile not found"
    exit 1
fi

test_step ".dockerignore exists"
if [ -f ".dockerignore" ]; then
    pass
else
    warn ".dockerignore not found (optional but recommended)"
fi

test_step "Makefile has docker targets"
if grep -q "docker-run:" Makefile; then
    pass
else
    fail "Makefile missing docker-run target"
    exit 1
fi

test_step "README has DockerHub link"
if grep -q "zli577/cgm-report" README.md; then
    pass
else
    fail "README missing correct DockerHub link"
    exit 1
fi

test_step "report/ directory exists"
if [ -d "report" ]; then
    pass
else
    fail "report/ directory not found"
    exit 1
fi

echo ""
echo "Phase 2: Docker Environment Checks"
echo "-----------------------------------"

test_step "Docker is installed"
if command -v docker &> /dev/null; then
    pass
else
    fail "Docker not installed or not in PATH"
    exit 1
fi

test_step "Docker daemon is running"
if docker ps &> /dev/null; then
    pass
else
    fail "Docker daemon not running - start Docker Desktop"
    exit 1
fi

test_step "Docker login status"
if docker info 2>/dev/null | grep -q "Username"; then
    pass
else
    warn "Not logged into DockerHub (needed for push)"
fi

echo ""
echo "Phase 3: Build and Local Test"
echo "-----------------------------------"

test_step "Docker image can be built"
if docker build -t zli577/cgm-report:latest . &> /tmp/docker_build.log; then
    pass
else
    fail "Docker build failed - check /tmp/docker_build.log"
    exit 1
fi

test_step "Docker image exists locally"
if docker images zli577/cgm-report:latest | grep -q latest; then
    pass
else
    fail "Image not found after build"
    exit 1
fi

echo ""
echo "Cleaning previous outputs..."
rm -rf report/*
mkdir -p report

test_step "Docker container can run"
if make docker-run &> /tmp/docker_run.log; then
    pass
else
    fail "Docker run failed - check /tmp/docker_run.log"
    exit 1
fi

test_step "HTML report generated"
if [ -f "report/participants.html" ]; then
    pass
else
    fail "participants.html not found in report/"
    exit 1
fi

test_step "HTML report not empty"
if [ -s "report/participants.html" ]; then
    pass
else
    fail "participants.html is empty"
    exit 1
fi

test_step "PNG figures generated"
PNG_COUNT=$(ls report/*.png 2>/dev/null | wc -l)
if [ "$PNG_COUNT" -ge 5 ]; then
    pass
    echo "   (Found $PNG_COUNT PNG files)"
else
    warn "Expected at least 5 PNG files, found $PNG_COUNT"
fi

echo ""
echo "Phase 4: DockerHub Checks"
echo "-----------------------------------"

test_step "Can pull from DockerHub"
if docker pull zli577/cgm-report:latest &> /tmp/docker_pull.log; then
    pass
    echo "   (Image is available on DockerHub)"
else
    warn "Cannot pull from DockerHub - you may need to push first"
    echo "   Run: docker push zli577/cgm-report:latest"
fi

echo ""
echo "Phase 5: Git Status"
echo "-----------------------------------"

test_step "Inside git repository"
if git rev-parse --git-dir &> /dev/null; then
    pass
else
    fail "Not in a git repository"
    exit 1
fi

test_step "No uncommitted changes to Docker files"
if git diff --quiet Dockerfile Makefile README.md 2>/dev/null; then
    warn "Changes not staged - run: git add -A"
else
    # Check if staged
    if git diff --cached --quiet Dockerfile Makefile README.md 2>/dev/null; then
        warn "Changes staged but not committed"
    else
        pass
        echo "   (All Docker files committed)"
    fi
fi

test_step "report/*.html ignored by git"
if git check-ignore report/participants.html &> /dev/null; then
    pass
else
    fail ".gitignore not properly configured for report/"
fi

test_step "report/.gitkeep tracked by git"
if git ls-files | grep -q "report/.gitkeep"; then
    pass
else
    warn "report/.gitkeep not tracked (run: git add report/.gitkeep)"
fi

echo ""
echo "=========================================="
echo "Test Results: $TESTS_PASSED/$TESTS_TOTAL passed"
echo "=========================================="
echo ""

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Push to DockerHub:     docker push zli577/cgm-report:latest"
    echo "  2. Make repo public:      https://hub.docker.com/r/zli577/cgm-report/settings"
    echo "  3. Commit to git:         git add -A && git commit -m 'Add Docker support'"
    echo "  4. Push to GitHub:        git push origin main"
    echo ""
    echo "Optional final test:"
    echo "  docker rmi zli577/cgm-report:latest && make docker-run"
    echo "  (Should pull from DockerHub and generate report)"
    echo ""
else
    echo -e "${RED}⚠️  Some tests failed - please fix before proceeding${NC}"
    echo ""
    echo "Check log files in /tmp/ for details:"
    echo "  - /tmp/docker_build.log"
    echo "  - /tmp/docker_run.log"
    echo "  - /tmp/docker_pull.log"
    exit 1
fi
