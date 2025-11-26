.PHONY: all report figures clean install

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