#!/bin/bash

export app_dir=$(pwd)
awk_read_onoff() {
    awk -v pat=$1 '$0~pat {print $3}' namelist.modify
}

shapeonoff=$(awk_read_onoff shapefile_ON_OFF)
boundonoff=$(awk_read_onoff bounding_box_ON_OFF)
pointsonoff=$(awk_read_onoff points_list_ON_OFF)
wholeonoff=$(awk_read_onoff whole_domain_ON_OFF)

sumopts=$((shapeonoff + boundonoff + pointsonoff + wholeonoff))
if [[ $sumopts -gt 1 ]]; then
    echo "  Warning: more than one task is enabled"
    echo "  Select only one task in namelist.modify and run again"
    exit
fi
if [[ $sumopts -eq 0 ]]; then
    echo "  Warning: no section is activated"
    echo "  Select one task or section in namelist.wrf and run again"
    exit
fi

export wrf_variable=$(sed -n "/wrf_variable/s/.*=//p" namelist.modify | tr -d " ")
export wrf_replacement_variable=$(sed -n "/wrf_replacement_variable/s/.*=//p" namelist.modify | tr -d " ")
export number_of_domains=$(sed -n "/number_of_domains/s/.*=//p" namelist.modify | tr -d " ")
export domain_1=$(sed -n "/domain_1/s/.*=//p" namelist.modify | tr -d " ")
export domain_2=$(sed -n "/domain_2/s/.*=//p" namelist.modify | tr -d " ")
export domain_3=$(sed -n "/domain_3/s/.*=//p" namelist.modify | tr -d " ")
export domain_4=$(sed -n "/domain_4/s/.*=//p" namelist.modify | tr -d " ")
export domain_5=$(sed -n "/domain_5/s/.*=//p" namelist.modify | tr -d " ")

# echo $wrf_replacement_variable
echo $wrf_replacement_variable >$app_dir"/modules/totalequation.txt"
cd $app_dir/modules
ncl separation.ncl >/dev/null

if [[ $wholeonoff == 1 ]]; then
    filename="whole_domain.ncl"
    filename_copy=$filename"_copy"
    sed '/added_new_line_by_sed/ d' $filename >$filename_copy #cleaning previous vars added by sed
    mv $filename_copy $filename                               #recycling the code to its prestine condition
    count=$(cat variables.txt | wc -l)
    mm=0
    while [ $mm -lt $count ]; do
        onevar[$mm]=$(sed -n "$((mm + 1)) p" variables.txt)
        sed '/shell script/ a '${onevar[$mm]}' = varlist['$mm']  ;;;added_new_line_by_sed' $filename >$filename_copy
        mv $filename_copy $filename
        mm=$((mm + 1))
    done
    equation=$(cat totalequation.txt)
    sed '/equation from namelist.wrf/ a polynomial = '$equation'  ;;;added_new_line_by_sed' $filename >$filename_copy
    mv $filename_copy $filename
    ncl -Qn whole_domain.ncl
fi

if [[ $shapeonoff == 1 ]]; then
    myvar="path_to_shapefile"
    export shape_path=$(sed -n "/$myvar/s/.*=//p" namelist.modify | tr -d " ")
    unset myvar
fi

# domain_1=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d01_2021-01-22_00:00:00
# domain_2=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d02_2021-01-22_00:00:00
# domain_3=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d03_2021-01-22_00:00:00
