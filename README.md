# Analysis of Census LEHD LODES Origin Destination data
Part 1: determine census tracts with the highest number of workers living outside of the tract's county.

## Running
Running `make` will download the LEHD data, run the Jupyter notebook, and join the processed data to 2010 census tract geometries.

This assumes you have an python environment setup called `jobs_map_env` and have the `mapshaper` cli tool available globally. See [Environment Setup](#environment-setup) for more.

## Notebooks
To run the notebooks locally first activate the `conda` environment:

```
source activate jobs_map_env
```

Then do:

```
jupyter notebook
```

## Data
Data sourced from:

https://lehd.ces.census.gov/data/lodes/LODES7/ca/od/ca_od_main_JT00_2015.csv.gz
https://lehd.ces.census.gov/data/lodes/LODES7/ca/ca_xwalk.csv.gz

The LEHD origin destination data is very large so is not checked into this repo.

## Environment Setup
For using Python Pandas and GeoPandas for data processing.

First, install [Miniconda3](https://conda.io/miniconda.html) and set up a Python virtual environment with dependencies.

```bash
# install miniconda, for more see: https://pandas.pydata.org/pandas-docs/stable/install.html
bash Miniconda3-latest-MacOSX-x86_64.sh

# make sure to add conda to your PATH
export PATH="/Users/chrishenrick/miniconda3/bin":$PATH

# create virtual env
conda create -n jobs_map_env python

# activate env
source activate jobs_map_env

# install pandas
conda install pandas

# install pip
conda install pip

# install shapely, geos, gdal
conda install shapely
conda install gdal

# install geopandas
conda install -c conda-forge geopandas

# install jupyter
python -m pip install --upgrade pip
python -m pip install jupyter

# to deactivate the virtual env
source deactivate
```
