#!/bin/bash
# Contact person: Amirhossein Nikfal <https://github.com/anikfal>

export app_dir=$(pwd)
awk_read_onoff() {
    awk -v pat=$1 '$0~pat {print $3}' namelist.tailor
}

shapeonoff=$(awk_read_onoff shapefile_ON_OFF)
boundonoff=$(awk_read_onoff bounding_box_ON_OFF)
pointsonoff=$(awk_read_onoff points_list_ON_OFF)
wholeonoff=$(awk_read_onoff whole_domain_ON_OFF)
geotiffonoff=$(awk_read_onoff geotiff_replace_ON_OFF)
sumopts=$((shapeonoff + boundonoff + pointsonoff + wholeonoff + geotiffonoff))
if [[ $sumopts -gt 1 ]]; then
    echo "  Warning: more than one task is enabled"
    echo "  Select only one task in namelist.tailor and run again"
    exit
fi
if [[ $sumopts -eq 0 ]]; then
    echo "  Warning: no section is activated"
    echo "  Select one task or section in namelist.wrf and run again"
    exit
fi

export number_of_domains=$(sed -n "/number_of_domains/s/.*=//p" namelist.tailor | tr -d " ")
if [[ $number_of_domains -gt 5 ]]; then
    echo Warning!
    echo number_of_domains cannot be more than 5
    echo set the correct number_of_domains and run again
    exit
fi
export domain_1=$(sed -n "/domain_1/s/.*=//p" namelist.tailor | tr -d " ")
export domain_2=$(sed -n "/domain_2/s/.*=//p" namelist.tailor | tr -d " ")
export domain_3=$(sed -n "/domain_3/s/.*=//p" namelist.tailor | tr -d " ")
export domain_4=$(sed -n "/domain_4/s/.*=//p" namelist.tailor | tr -d " ")
export domain_5=$(sed -n "/domain_5/s/.*=//p" namelist.tailor | tr -d " ")

if [[ $wholeonoff == 1 ]]; then
    export wrf_variable=$(sed -n "/wrf_variable/s/.*=//p" namelist.tailor | awk 'NR==1' | tr -d " ")
    export wrf_new_variable=$(sed -n "/wrf_new_variable/s/.*=//p" namelist.tailor | tr -d " ")
    echo $wrf_new_variable >$app_dir"/modules/totalequation.txt"
    cd $app_dir/modules
    ncl separation.ncl >/dev/null
    filename="whole_domain.ncl"
    filename_copy=$filename"_copy"
    sed '/added_new_line_by_sed/ d' $filename >$filename_copy #cleaning previous vars added by sed
    mv $filename_copy $filename                               #recycling the code to its prestine condition
    count=$(cat variables.txt | wc -l)
    mm=0
    while [ $mm -lt $count ]; do
        onevar[$mm]=$(sed -n "$((mm + 1)) p" variables.txt)
        sed '/shell script/ a '${onevar[$mm]}' := varlist['$mm']  ;;;added_new_line_by_sed' $filename >$filename_copy
        mv $filename_copy $filename
        mm=$((mm + 1))
    done
    equation=$(cat totalequation.txt)
    sed '/equation from namelist.wrf/ a polynomial := '$equation'  ;;;added_new_line_by_sed' $filename >$filename_copy
    mv $filename_copy $filename
    ncl -Qn whole_domain.ncl
fi

if [[ $shapeonoff == 1 ]]; then
    export shape_path=$(sed -n "/path_to_shapefile/s/.*=//p" namelist.tailor | tr -d " ")
fi

if [[ $geotiffonoff == 1 ]]; then
    gdal_translate --version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Warning: gdal_translate must be installed on the system."
        echo "Exiting ..."
        exit
    fi
    export geotiff_file=$(sed -n "/geotiff_file/s/.*=//p" namelist.tailor | tr -d " ")
    export wrf_variable=$(sed -n "/wrf_variable/s/.*=//p" namelist.tailor | awk 'NR==2' | tr -d " ")
    cd $app_dir/modules
    filename=$(basename $geotiff_file)
    export tiff2nc=$filename".nc"
    echo "Converting GeoTIFF to NetCDF ..."
    # gdal_translate -of NetCDF $geotiff_file $tiff2nc
    ncl -Q geotiff.ncl
fi

# gdal_translate -of NetCDF dem_full375.tif dem_full375.nc
