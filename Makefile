.PHONY: all report figures clean install docker-build docker-run docker-run-windows

all: report

install:
	@echo "Restoring R package environment..."
	Rscript -e "if (!requireNamespace('renv', quietly=TRUE)) install.packages('renv', repos='https://cloud.r-project.org'); renv::restore()"

report: figures
	@echo "Rendering R Markdown report..."
	Rscript -e "if (!requireNamespace('rmarkdown', quietly=TRUE)) install.packages('rmarkdown', repos='https://cloud.r-project.org'); rmarkdown::render('participants.Rmd', output_file = 'participants.html')"

figures:
	@echo "Generating CGM figures with R..."
	Rscript codes/cgm_plots.R

clean:
	@echo "Cleaning generated files..."
	-rm -f participants.html
	-rm -rf outputs/*.png
	-rm -rf report/*

# Docker targets
docker-build:
	@echo "Building Docker image..."
	docker build -t zli577/cgm-report:latest .

# For Mac/Linux
docker-run:
	@echo "Running Docker container to generate report..."
	@mkdir -p report
	docker run --rm \
		-v "$$(pwd)/report:/project/report" \
		-v "$$(pwd)/data:/project/data:ro" \
		zli577/cgm-report:latest \
		sh -c "make report && cp participants.html outputs/*.png report/"

# For Windows (use %CD% instead of $$(pwd))
docker-run-windows:
	@echo "Running Docker container to generate report (Windows)..."
	@if not exist report mkdir report
	docker run --rm \
		-v "%CD%/report:/project/report" \
		-v "%CD%/data:/project/data:ro" \
		zli577/cgm-report:latest \
		sh -c "make report && cp participants.html outputs/*.png report/"