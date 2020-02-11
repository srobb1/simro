## Customize Makefile settings for simro
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


#########################################
###         Cleaning imports       ######
#########################################
# might want to change this to use imports/..owl in the remove statment instead of using the mirror file $> mirror/owl $@ imports/owl

#imports/clo_import.owl: mirror/clo.owl
#	$(ROBOT) remove --input $< -t CLO:0000015 -t OBI:0000293 --preserve-structure false \
	anannotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@
	
#imports/clo_import.owl: mirror/cl.owl
#	$(ROBOT) remove --input $< -t CLO:0000015 -t OBI:0000293 --preserve-structure false \
	anannotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@

#imports/obi_import.owl: mirror/obi.owl
#	$(ROBOT) remove --input $< -t CLO:0000015 -t OBI:0000293 --preserve-structure false \
	annotate --ontology-iri $(ONTBASE)/$@ --version-iri $(ONTBASE)/releases/$(TODAY)/$@ --output $@.tmp.owl && mv $@.tmp.owl $@




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
