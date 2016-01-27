MAPSHAPER = ./node_modules/.bin/mapshaper

RAW_DIR = raw
SPLIT_DIR = split
TOPOJSON_DIR = topojson

COUNTY_SHP = $(RAW_DIR)/County_MOI_1041215.shp
TOWN_SHP = $(RAW_DIR)/Town_MOI_1041215.shp
VILLAGE_SHP = $(RAW_DIR)/Village_NLSC_1041215.shp

SPLIT_COUNTIES_PATH = $(SPLIT_DIR)/counties.shp
SPLIT_TOWNS_PATH = $(SPLIT_DIR)/towns
SPLIT_VILLAGES_PATH = $(SPLIT_DIR)/villages

TOPOJSON_COUNTIES_PATH = $(TOPOJSON_DIR)/counties.json
TOPOJSON_TOWNS_PATH = $(TOPOJSON_DIR)/towns
TOPOJSON_VILLAGES_PATH = $(TOPOJSON_DIR)/villages
TOPOJSON_TOWN_FILES = $(patsubst $(SPLIT_TOWNS_PATH)/%.shp, $(TOPOJSON_TOWNS_PATH)/%.json, $(wildcard $(SPLIT_TOWNS_PATH)/*.shp))
TOPOJSON_VILLAGE_FILES = $(patsubst $(SPLIT_VILLAGES_PATH)/%.shp, $(TOPOJSON_VILLAGES_PATH)/%.json, $(wildcard $(SPLIT_VILLAGES_PATH)/*.shp))


SPLIT_COUNTY_OPTS = \
		-rename-fields id=County_ID \
		-join csv/counties.csv keys=id,id field-types=id:str \
		-filter-fields id,name
SPLIT_TOWN_OPTS = \
		-rename-fields id=Town_ID \
		-join csv/towns.csv keys=id,id field-types=id:str \
		-split County_ID \
		-filter-fields id,name
SPLIT_VILLAGE_OPTS = \
		-rename-fields id=VILLAGE_ID \
		-join csv/villages.csv keys=id,id field-types=id:str \
		-split TOWN_ID \
		-filter-fields id,name


TOPOJSON_COUNTY_OPTS = -simplify interval=400
TOPOJSON_TOWN_OPTS = -simplify interval=200
TOPOJSON_VILLAGE_OPTS = -simplify interval=100


all: split-all topojson-all


$(SPLIT_COUNTIES_PATH): $(COUNTY_SHP)
	@mkdir -p $(dir $@)
	@${MAPSHAPER} $< encoding=big5 name=counties \
		$(SPLIT_COUNTY_OPTS) \
		-o force $@

$(SPLIT_TOWNS_PATH): $(TOWN_SHP)
	@mkdir -p $@
	@${MAPSHAPER} $< encoding=big5 name=towns \
		$(SPLIT_TOWN_OPTS) \
		-o force $@

$(SPLIT_VILLAGES_PATH): $(VILLAGE_SHP)
	@mkdir -p $@
	@${MAPSHAPER} $< encoding=big5 name=villages \
		$(SPLIT_VILLAGE_OPTS) \
		-o force $@

split-counties: $(SPLIT_COUNTIES_PATH)
split-towns: $(SPLIT_TOWNS_PATH)
split-villages: $(SPLIT_VILLAGES_PATH)
split-all: split-counties split-towns split-villages


$(TOPOJSON_COUNTIES_PATH): $(SPLIT_COUNTIES_PATH)
	@mkdir -p $(dir $@)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_COUNTY_OPTS) \
		-o force bbox $@ format=topojson

$(TOPOJSON_TOWNS_PATH):
	@mkdir -p $@

$(TOPOJSON_TOWNS_PATH)/%.json: $(SPLIT_TOWNS_PATH)/%.shp | $(TOPOJSON_TOWNS_PATH)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_TOWN_OPTS) \
		-o force bbox $@ format=topojson

$(TOPOJSON_VILLAGES_PATH):
	@mkdir -p $@

$(TOPOJSON_VILLAGES_PATH)/%.json: $(SPLIT_VILLAGES_PATH)/%.shp | $(TOPOJSON_VILLAGES_PATH)
	@${MAPSHAPER} $< encoding=utf-8 name=map \
		$(TOPOJSON_VILLAGE_OPTS) \
		-o force bbox $@ format=topojson

topojson-counties: $(TOPOJSON_COUNTIES_PATH)
topojson-towns: $(TOPOJSON_TOWN_FILES)
topojson-villages: $(TOPOJSON_VILLAGE_FILES)
topojson-all: topojson-counties topojson-towns topojson-villages


clean-split-counties:
	rm -f $(SPLIT_COUNTIES_PATH)

clean-split-towns:
	rm -rf $(SPLIT_TOWNS_PATH)

clean-split-villages:
	rm -rf $(SPLIT_VILLAGES_PATH)

clean-split:
	rm -rf $(SPLIT_DIR)

clean-topojson-counties:
	rm -f $(TOPOJSON_COUNTIES_PATH)

clean-topojson-towns:
	rm -rf $(TOPOJSON_TOWNS_PATH)

clean-topojson-villages:
	rm -rf $(TOPOJSON_VILLAGES_PATH)

clean-topojson:
	rm -rf $(TOPOJSON_DIR)

clean: clean-split clean-topojson


.PHONY: clean \
	clean-split-counties clean-split-towns clean-split-villages clean-split \
	clean-topojson-counties clean-topojson-towns clean-topojson-villages clean-topojson
