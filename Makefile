datadir = data

.PHONY: all clean clean_processed data

all: tracts_2010_greater_bay_area_4326.shp tracts_2010_4326_od.shp tracts_2010_4326_od_ratio.shp

clean:
	rm -rf $(datadir)

clean_processed:
	rm -rf $(datadir)/*.csv $(datadir)/*.shp $(datadir)/*.dbf $(datadir)/*.prj $(datadir)/*.shx

data:
	mkdir -p $(datadir)

nhgis0004_shapefile_tl2010_us_tract_2010.zip: data
	wget -O $(datadir)/$@ https://www.dropbox.com/s/cjk8bnh2xd9o8p7/$@?dl=1

# creates a shapefile in wgs84 of census tracts for the 9 county SF Bay Area,
# plus some additional neighboring counties
tracts_2010_greater_bay_area_4326.shp: nhgis0004_shapefile_tl2010_us_tract_2010.zip
	. ./activate_venv.sh; \
	cd $(datadir); \
	ogr2ogr \
		-overwrite \
		-skipfailures \
		-sql "select substr(GEOID10, 2) as GEOID, TRACTCE10 from US_tract_2010 where STATEFP10 = '06' AND ALAND10 > 0 AND COUNTYFP10 IN ('001', '013', '041', '047', '055', '067', '069', '075', '077', '081', '085', '087', '095', '097', '099')" \
		-t_srs EPSG:4326 \
		$@ \
		/vsizip/nhgis0004_shapefile_tl2010_us_tract_2010.zip/US_tract_2010.shp; \

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
