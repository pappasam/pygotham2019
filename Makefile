PLANT_SRCS = $(wildcard *.plantuml)
PLANT_IMGS = $(patsubst %.plantuml,instance/%.svg,$(PLANT_SRCS))

.PHONY: help
help:  ## Prints this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk \
		'BEGIN {FS = ":.*?## "};{printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: poetry.lock fonts  ## Initialize project, install dependencies

.PHONY: open-dev
open-dev:  ## Open presentation served from the dev server
	google-chrome http://localhost:8000

.PHONY: open-prod
open-prod:  ## Open the already-built presentation
	google-chrome build/localhost:8000/index.html

.PHONY: build-pdf
build-pdf: presentation.pdf  ## Build pdf version of presentation

.PHONY: plantuml
plantuml: $(PLANT_IMGS)  ## Build any plantuml diagrams

.PHONY: venn
venn: img/venn_packaging.svg

.PHONY: serve
serve: presentation.rst plantuml venn ## Serve in development mode
	poetry run hovercraft $<

.PHONY: clean
clean:  ## Clean up any assets installed during development
	-rm -r build
	-rm -r fonts
	-rm instance/*

build: presentation.rst setup plantuml venn  ## Build local presentation
	wget \
		--adjust-extension \
		--convert-links \
		--mirror \
		--no-parent \
		--page-requisites \
		--span-hosts \
		--ignore-tags=a,iframe,video,source \
		--directory-prefix=$@ \
		localhost:8000

%.pdf: %.rst poetry.lock fonts plantuml
	cat $< |\
		grep -v ':class:' |\
		grep -v ':data-x:' |\
		grep -v ':data-y:' |\
		grep -v ':data-z:' |\
		pandoc -f rst -o instance/pandoc.pdf \
			-V geometry:"paperheight=11in, paperwidth=8.5in, margin=0.75in" \
			--filter=pandoc-latex-newpage \
			--pdf-engine=xelatex
	pdfnup \
		--nup 2x1 \
		-o instance/pdfnup.pdf \
		instance/pandoc.pdf
	gs \
		-dNOPAUSE \
		-dBATCH \
		-sDEVICE=pdfwrite \
		-dCompatibilityLevel=1.4 \
		-dPDFSETTINGS="/ebook" \
		-sOutputFile=$@ \
		instance/pdfnup.pdf

instance/venn_packaging.svg: venn.py
	python $<

instance/%.svg: %.plantuml
	plantuml -tsvg -o instance $<

poetry.lock: pyproject.toml
	poetry install

fonts:
	wget -O $@.zip https://github.com/mozilla/Fira/archive/4.202.zip
	unzip -d $@ $@.zip
	rm $@.zip
