#!/bin/bash

# sed -n '/Variable/s/.*=//p' namelist.modify | tr -d " "

awk_read_onoff() {
    awk -v pat=$1 '$0~pat {print $3}' namelist.modify
}

shapeonoff=$(awk_read_onoff shapefile_ON_OFF)
boundonoff=$(awk_read_onoff bounding_box_ON_OFF)
pointsonoff=$(awk_read_onoff points_list_ON_OFF)
wholeonoff=$(awk_read_onoff whole_domain_ON_OFF)

sumopts=$((shapeonoff + boundonoff + pointsonoff + wholeonoff))
if [[ $sumopts -gt 1 ]]; then
    echo ""
    echo "  More than one task is enabled"
    echo "  Select only one task in namelist.modify and run again"
    echo ""
fi
if [[ $sumopts -eq 0 ]]; then
    echo ""
    echo "  No section is activated"
    echo "  Select one task or section in namelist.wrf and run again"
    echo ""
fi

if [[ $shapeonoff == 1 ]]; then
    myvar="path_to_shapefile"
    export shape_path=`sed -n "/$myvar/s/.*=//p" namelist.modify | tr -d " "`
    unset myvar
fi

echo $shape_path

domain_1=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d01_2021-01-22_00:00:00
domain_2=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d02_2021-01-22_00:00:00
domain_3=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d03_2021-01-22_00:00:00