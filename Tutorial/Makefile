# Copyright 2015 Nicolas Melot
#
# This file is part of QDM.
#
# QDM is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# QDM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with QDM. If not, see <http://www.gnu.org/licenses/>.
#


## Make a symbol that matches a space
space :=
space +=

TMP=tmp

FIG_ROOT=figures
FIG_SUBDIR=.
FIG_DIR=$(foreach var,$(FIG_SUBDIR),$(FIG_ROOT)/$(var))
FIG_EXTENSION=svg png fig eps ppm jpg xcf gif
FIG_LATEX=pdf

#+18 for "off" energy model
#-18 for "simple" energy model"
# Anything strictly below 70 has no energy model

RASTERIZE=0
BITMAP_MAX_SIZE=500

# Enable GNU make secondary expansion feature
.SECONDEXPANSION:

FIG=$(foreach var,$(FIG_DIR),$(foreach ext,$(FIG_EXTENSION),$(wildcard $(var)/*.$(ext))))
FIG_TMP=$(foreach ext,$(FIG_EXTENSION),$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%))))

ALL_TMP=$(PDFSVG) $(PDFPNG) $(PDFFIG) $(PDFEPS) $(PDFJPG)

## Targets asked for running, or default target if none
TARGETS=$(if $(MAKECMDGOALS),$(MAKECMDGOALS),$(DEFAULT))

ifeq ($(filter-out wipe,$(MAKECMDGOALS)),$(MAKECMDGOALS))
DEPS=$(TMP) $(ALL_TMP) $(FIG_TMP)
else
DEPS=
endif

## Make all targets called dependant on some action to be run beforehand
$(TARGETS): $(DEPS) Makefile

include LaTeX.mk

$(TMP): Makefile
	mkdir -p $@

## SVG
$(foreach ext,svg,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.svg,$$@) Makefile
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	inkscape --export-area-page -d 720 -A $@ $<
else
	$(if $(filter-out 0,$(shell echo "`inkscape --query-width $< | xargs echo`" '>' "`inkscape --query-height $< | xargs echo`" | bc)),inkscape --export-area-page --export-background-opacity=0 -w $(BITMAP_MAX_SIZE) -e $(patsubst %.$(FIG_LATEX),%.png,$@) $<,inkscape --export-area-page --export-background-opacity=0 -h $(BITMAP_MAX_SIZE) -e $(patsubst %.$(FIG_LATEX),%.png,$@) $<)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## FIG
$(foreach ext,fig,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.fig,$$@) Makefile
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	fig2dev -L $(FIG_LATEX) $< > $@
else
	fig2dev -L $(FIG_LATEX) $< > $@
	convert $@ -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.$(FIG_LATEX),%.png,$@)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## EPS
$(foreach ext,eps,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.eps,$$@) Makefile
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	convert $< $@
else
	convert $< -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.$(FIG_LATEX),%.png,$@)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## JPG
$(foreach ext,jpg,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.jpg,$$@)
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	convert $< $@
else
	convert $< -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.$(FIG_LATEX),%.png,$@)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## PPM
$(foreach ext,ppm,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.ppm,$$@)
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	convert $< $@
else
	convert $< -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.$(FIG_LATEX),%.png,$@)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## PNG
$(foreach ext,png,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.png,$$@)
	mkdir -p `dirname $@`
ifeq ($(if $(RASTERIZE),$(filter-out 0,$(RASTERIZE)),),)
	convert $< $@
else
	convert $< -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.$(FIG_LATEX),%.png,$@)
	convert $(patsubst %.$(FIG_LATEX),%.png,$@) $@
endif

## XCF
$(foreach ext,xcf,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.xcf,$$@)
	mkdir -p `dirname $@`
ifeq ($(if $(BITMAP_MAX_SIZE),$(filter-out 0,$(BITMAP_MAX_SIZE)),),)
	xcf2png $< -o $(patsubst %.pdf,%.png,$@)
	convert $(patsubst %.pdf,%.png,$@) $@
else
	xcf2png $< -o $(patsubst %.pdf,%_full.png,$@)
	convert $(patsubst %.pdf,%_full.png,$@) -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $(patsubst %.pdf,%.png,$@)
	convert $(patsubst %.pdf,%.png,$@) $@
endif

## GIF
$(foreach ext,gif,$(patsubst %.$(ext),%.$(FIG_LATEX),$(filter %.$(ext),$(FIG:$(FIG_ROOT)/%=$(TMP)/%)))): $$(patsubst $(TMP)/%.$(FIG_LATEX),$(FIG_ROOT)/%.gif,$$@)
	mkdir -p `dirname $@`
ifeq ($(if $(BITMAP_MAX_SIZE),$(filter-out 0,$(BITMAP_MAX_SIZE)),),)
	convert $< $@
else
	convert $< -resize "$(BITMAP_MAX_SIZE)"'x'"$(BITMAP_MAX_SIZE)"'>' $@
endif

wipe:
	$(RM) *.pdf *.dvi *.ps *~ *.aux *.log *.mk *.bbl *.blg *.toc *.nav *.snm
	$(RM) $(FIG_TMP) $(FIG_TMP:%.$(FIG_LATEX)=%.png) $(FIG_TMP:%.$(FIG_LATEX)=%_full.png)
	$(if $(shell find $(TMP) -name \*.*),,$(RM) -rf $(TMP))

.PHONY: wipe
