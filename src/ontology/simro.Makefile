## Customize Makefile settings for simro
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


#########################################
###         Cleaning imports       ######
#########################################
# might want to change this to use imports/..owl in the remove statment instead of using the mirror file $> mirror/owl $@ imports/owl

## ONTOLOGY: clo
## Copy of clo is re-downloaded whenever source changes
mirror/clo.trigger: $(SRC)

mirror/clo.owl: mirror/clo.trigger
	@if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I https://raw.githubusercontent.com/srobb1/simr_imports/master/clo_import.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
	$(ROBOT) remove --input $@ -t CLO:0000015 -t OBI:0000293 --preserve-structure false --output $@.tmp.owl && mv $@.tmp.owl $@

.PRECIOUS: mirror/%.owl

## ONTOLOGY: cl
## Copy of cl is re-downloaded whenever source changes
#mirror/cl.trigger: $(SRC)

#mirror/cl.owl: mirror/cl.trigger
#	@if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I http://purl.obolibrary.org/obo/cl/cl-base.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
#	$(ROBOT) remove --input $@ -t CLO:0000015 -t OBI:0000293 --preserve-structure false --output $@.tmp.owl && mv $@.tmp.owl $@

#.PRECIOUS: mirror/%.owl

## ONTOLOGY: obi
## Copy of obi is re-downloaded whenever source changes
#mirror/obi.trigger: $(SRC)

#mirror/obi.owl: mirror/obi.trigger
#	@if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/obi.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
#	$(ROBOT) remove --input $@ -t CLO:0000015 -t OBI:0000293 --preserve-structure false --output $@.tmp.owl && mv $@.tmp.owl $@

#.PRECIOUS: mirror/%.owl






#########################################
### Generating all ROBOT templates ######
#########################################

TEMPLATESDIR=../templates

TEMPLATES=$(patsubst %.tsv, $(TEMPLATESDIR)/%.owl, $(notdir $(wildcard $(TEMPLATESDIR)/*.tsv)))

$(TEMPLATESDIR)/%.owl: $(TEMPLATESDIR)/%.tsv $(SRC)
	$(ROBOT) merge -i $(SRC) template --template $< --output $@ && \
	$(ROBOT) annotate --input $@ --ontology-iri $(ONTBASE)/components/$*.owl -o $@

templates: $(TEMPLATES)
	echo $(TEMPLATES)
