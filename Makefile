VPATH = .:assets
vpath %.html .:_includes:_layouts:_site
vpath %.scss assets/css
vpath %.xml _site
vpath %.yaml spec

PANDOC    = $(filter-out README.md,$(wildcard *.md))
HTML     := $(patsubst %.md,_site/%.html,$(PANDOC))

deploy : jekyll $(HTML)

pandoc : $(HTML)

racionalismo-plano.pdf : racionalismo-plano.tex basica.bib \
	complementar.bib fontes.bib
	docker run -i -v "`pwd`:/data" --user "`id -u`:`id -g`" \
		-v "`pwd`/assets/fonts:/usr/share/fonts" blang/latex:ctanfull \
		latexmk -pdflatex="xelatex" -cd -f -interaction=batchmode -pdf $<

racionalismo-plano.tex : pdf.yaml plano.md
	docker run --rm -v "`pwd`:/data" --user "`id -u`:`id -g`" \
		-v "`pwd`/assets/fonts:/usr/share/fonts" \
		pandoc/crossref:2.10 -o $@ -d $^

%.pdf : pdf.yaml %.md
	docker run --rm -v "`pwd`:/data" --user "`id -u`:`id -g`" \
		-v "`pwd`/assets/fonts:/usr/share/fonts" \
		pandoc/latex:2.10 -o $@ -d $^

jekyll : clean $(HTML) README.md
	docker run --rm -v "`pwd`:/srv/jekyll" \
		jekyll/jekyll:4.1.0 /bin/bash -c "chmod 777 /srv/jekyll && jekyll build"

_site/%.html : html.yaml %.md
	docker run --rm -v "`pwd`:/data" --user "`id -u`:`id -g`" \
		pandoc/core:2.10 -o $@ -d $^

serve :
	docker run --rm -p 4000:4000 -h 127.0.0.1 \
		-v "`pwd`:/srv/jekyll" -it jekyll/jekyll:4.1.0 \
		jekyll serve --skip-initial-build --no-watch

styles :
	git clone https://github.com/citation-style-language/styles.git

clean :
	rm -rf styles *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls *.log *.run.xml
