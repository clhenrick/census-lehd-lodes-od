datadir = data

.PHONY: all clean clean_processed data

all: tracts_2010_4326_od.shp tracts_2010_4326_od_ratio.shp

clean:
	rm -rf $(datadir)

clean_processed:
	rm -rf $(datadir)/*.csv $(datadir)/*.shp $(datadir)/*.dbf $(datadir)/*.prj $(datadir)/*.shx

data:
	mkdir -p $(datadir)

ca_od_main_JT00_2015.csv.gz: data
	wget https://lehd.ces.census.gov/data/lodes/LODES7/ca/od/$@ -P $(datadir)

ca_xwalk.csv.gz: data
	wget https://lehd.ces.census.gov/data/lodes/LODES7/ca/$@ -P $(datadir)

lehd_od_tracts_high_migration.csv: ca_od_main_JT00_2015.csv.gz ca_xwalk.csv.gz
	. ./activate_venv.sh; \
	jupyter nbconvert --to notebook --execute --inplace --allow-errors --ExecutePreprocessor.timeout=-1 census-lehd-od-analysis.ipynb

lehd_od_tracts_home_ratio.csv: ca_od_main_JT00_2015.csv.gz ca_xwalk.csv.gz
	. ./activate_venv.sh; \
	jupyter nbconvert --to notebook --execute --inplace --allow-errors --ExecutePreprocessor.timeout=-1 proportion-commute-away-vs-local.ipynb

tracts_2010_4326_od.shp: lehd_od_tracts_high_migration.csv
	mapshaper -i tracts_2010_4326.json -join $(datadir)/lehd_od_tracts_high_migration.csv keys=GEOID,trct -o $(datadir)/$@ format=shapefile

tracts_2010_4326_od_ratio.shp: lehd_od_tracts_home_ratio.csv
	mapshaper -i tracts_2010_4326.json -join $(datadir)/lehd_od_tracts_home_ratio.csv keys=GEOID,trct -o $(datadir)/$@ format=shapefile
