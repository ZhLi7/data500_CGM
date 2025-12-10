# Quick Start: Docker Workflow

## For Your Instructor/Grader (No Prerequisites Required)

Just run:

```bash
# Mac/Linux
make docker-run

# Windows
make docker-run-windows
```

This will:
✓ Automatically pull the image from DockerHub
✓ Generate the report in the `report/` directory
✓ No local R installation needed
✓ No manual package installation needed

---

## For You: Setup Before Submission

### 1. Build and Test Locally

```bash
make docker-build
make docker-run
```

Check that `report/participants.html` was created.

### 2. Push to DockerHub

```bash
docker login
docker push zli577/cgm-report:latest
```

### 3. Make Repository Public

Go to https://hub.docker.com/ → Your repository → Settings → Make Public

### 4. Update README

The README has already been updated with your DockerHub username `zli577`.
Verify the link: https://hub.docker.com/r/zli577/cgm-report

### 5. Test from DockerHub

```bash
docker rmi zli577/cgm-report:latest  # Delete local copy
make docker-run                       # Should pull from DockerHub
```

✅ **If report generates successfully, you're done!**

---

## File Checklist

```
✓ Dockerfile                  (created)
✓ .dockerignore              (created)
✓ Makefile                   (updated with docker-run)
✓ README.md                  (updated with Docker instructions)
✓ report/.gitkeep            (created)
✓ .gitignore                 (updated to ignore report outputs)
✓ DOCKER_SETUP_GUIDE.md      (this guide)
```

---

## Submission Requirements Met

✅ **GitHub:**
- Dockerfile in repository root
- README.md with build instructions
- README.md with DockerHub link
- README.md with run instructions

✅ **DockerHub:**
- Public repository available

✅ **Makefile:**
- `docker-run` target with no prerequisites
- Mounts empty `report/` directory
- Works on Mac/Linux (docker-run) and Windows (docker-run-windows)
- Clear instructions in README

---

## What Gets Generated

After `make docker-run`:

```
report/
├── participants.html    ← Main deliverable
├── 1007.png
├── 1014.png
├── 1024.png
├── 1052.png
├── 1055.png
├── 1062.png
└── 1066.png
```

---

## Important Notes

- **No prerequisites for grader:** They just run `make docker-run`
- **Platform-agnostic:** Works on Mac, Linux, and Windows
- **Data isolation:** Original data files never modified
- **Fully reproducible:** Locked R packages via renv.lock
- **Clean execution:** Container auto-removes after completion

---

## If Something Goes Wrong

### Image won't pull?
Check DockerHub repository is PUBLIC

### Permission denied?
Make sure Docker Desktop is running

### Windows path issues?
Use `make docker-run-windows` not `make docker-run`

### Need to rebuild?
```bash
make docker-build
docker push zli577/cgm-report:latest
```

---

See `DOCKER_SETUP_GUIDE.md` for detailed instructions.
