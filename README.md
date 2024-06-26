# WRFtailor

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12581503.svg)](https://doi.org/10.5281/zenodo.12581503)

### Tailoring and modification of the WRF input data over an area of interest

**Modify your WRF input data, in the same simple way as you run the WRF model!**

WRFtailor is a namelist-based tool, written in NCL and Bash scripts, to tailor and modify WRF input data (geo files, emissions data, etc).

## Main capabilities:
- Modify WRF input data over an AOI by a shapefile mask
- Modify WRF input data over an AOI by setting a lat/lon bounding box
- Modify WRF input data over specific grid points by setting a list of lat/lon coordinates
- Modify WRF input data over the area of the smallest domain (subdomain)
- Modify WRF input data by replacing the values from a GeoTIFF file into the WRF input data

## Sample applications:
![readme_image222](https://github.com/anikfal/wrftailor/assets/11738727/12f32123-505d-4354-8b6d-832b26a4b245)

## Installation:
Install NCL on a Linux machine (e.g. Fedora):
```bash
sudo dnf install ncl
```
That's enough for all of the WRFtailor's capabilities!

## Run WRFtailor:
1. ``` git clone git@github.com:anikfal/wrftailor.git ```
2. ``` cd wrftailor ```
3. ``` chmod +x wrftailor.sh modules/*.sh ```
4. Copy or link your WRF input files (e.g. geo files) in the WRFtailor directory
5. ``` ./wrftailor.sh ```
6. If everything has been set correctly, you can tailor and modify your WRF input data according to the enabled section in namelist.tailor.

## HTML Documentations:
Documentations with practical examples: https://wrftailor.readthedocs.io/en/latest

## YouTube Training Videos:
https://youtube.com/playlist?list=PL93HaRiv5QkA8uzFzcZkyTqkKPweJajrJ&si=kCJ3UNvnJlrGXFWd
