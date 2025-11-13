# Makefile to build the project report and helper artifacts

.PHONY: all report figures clean

all: report

# Generate example figures then render the R Markdown report
report: figures
	@echo "Rendering R Markdown report..."
	Rscript -e "if (!requireNamespace('rmarkdown', quietly=TRUE)) install.packages('rmarkdown', repos='https://cloud.r-project.org'); rmarkdown::render('particiants.Rmd', output_file = 'particiants.html')"

# Run the Python script that creates example CGM PNGs
figures:
	@echo "Generating example CGM figures..."
	@if [ -x ./.venv/bin/python ]; then \
		./.venv/bin/python codes/plot_cgm_examples.py; \
	else \
		python3 codes/plot_cgm_examples.py; \
	fi

clean:
	@echo "Cleaning generated files..."
	-rm -f particiants.html
	-rm -rf codes/outputs/*.png
