datadir = data

.PHONY: all clean data fetch_data run join

all: fetch_data join

clean:
	rm -rf $(datadir)

data:
	mkdir -p $(datadir)

fetch_data: data
	wget https://lehd.ces.census.gov/data/lodes/LODES7/ca/od/ca_od_main_JT00_2015.csv.gz -P $(datadir)
	wget https://lehd.ces.census.gov/data/lodes/LODES7/ca/ca_xwalk.csv.gz -P $(datadir)

run: fetch_data
	. ./activate_venv.sh; \
	jupyter nbconvert --to notebook --execute --inplace --allow-errors --ExecutePreprocessor.timeout=-1 census-lehd-od-analysis.ipynb

join: run
	mapshaper -i tracts_2010_4326.json -join $(datadir)/lehd_od_tracts_high_migration.csv keys=GEOID,trct -o $(datadir)/tracts_2010_4326_od.shp format=shapefile
