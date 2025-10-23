# WRFtailor

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.12581503.svg)](https://doi.org/10.5281/zenodo.12581503)

## Tailoring and Modification of WRF Input Data over an Area of Interest

**Modify your WRF input data as easily as running the WRF model!**

**WRFtailor** is a lightweight, namelist-based toolkit written in **NCL** and **Bash**.  
It allows users to **tailor and modify WRF input data** (e.g., *geo files, emissions data, etc.*) based on geographic boundaries or spatial datasets.

For detailed scientific background, see the paper:  
📄 [Nikfal, A. (2024). *WRFtailor: A toolkit for tailoring and modification of WRF input data.* *Geoscience Data Journal*](https://rmets.onlinelibrary.wiley.com/doi/10.1002/gdj3.70031)

---

## ✨ Main Capabilities

- Modify WRF input data over an area of interest (AOI) using a **shapefile mask**  
- Modify data using a **latitude/longitude bounding box**  
- Modify values at **specific grid points** (list of lat/lon coordinates)  
- Modify data within the **innermost WRF subdomain**  
- Replace variable values from a **GeoTIFF file** into WRF input data  

---

## 🧩 Example Applications

![Example](https://github.com/anikfal/wrftailor/assets/11738727/12f32123-505d-4354-8b6d-832b26a4b245)

---

## ⚙️ Installation

Install **NCL** on your Linux system (example for Fedora):

```bash
sudo dnf install ncl
```

That’s all you need to run all WRFtailor features!

## 🚀 Running WRFtailor
1. Clone the repository
    ```
    git clone git@github.com:anikfal/wrftailor.git
    cd wrftailor
    ```
2. Make scripts executable

    ```
    chmod +x wrftailor.sh modules/*.sh
    ```
3. Copy or link your WRF input files (e.g. geo_em.d01.nc) into the WRFtailor directory
4. Edit and configure your `namelist.tailor` file
5. Run
    ```
    ./wrftailor.sh
    ```
6. The tailored WRF input data will be generated according to the active sections in `namelist.tailor`.

## 📘 Documentation
Full documentation with practical examples is available at:

👉 https://wrftailor.readthedocs.io/en/latest

## 🎥 YouTube Training Series
Video tutorials are available here:

▶️ [WRFtailor YouTube Playlist](https://www.youtube.com/playlist?list=PL93HaRiv5QkA8uzFzcZkyTqkKPweJajrJ)

## 🧾 Citation
If you use WRFtailor in your research, please cite:

Nikfal, A. (2024). WRFtailor: A toolkit for tailoring and modification of WRF input data.
Geoscience Data Journal.

https://doi.org/10.1002/gdj3.70031