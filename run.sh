#!/bin/bash

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

export wrf_variable=`sed -n "/wrf_variable/s/.*=//p" namelist.modify | tr -d " "`
export new_value=`sed -n "/new_value/s/.*=//p" namelist.modify | tr -d " "`
export number_of_domains=`sed -n "/number_of_domains/s/.*=//p" namelist.modify | tr -d " "`
export domain_1=`sed -n "/domain_1/s/.*=//p" namelist.modify | tr -d " "`
export domain_2=`sed -n "/domain_2/s/.*=//p" namelist.modify | tr -d " "`
export domain_3=`sed -n "/domain_3/s/.*=//p" namelist.modify | tr -d " "`
export domain_4=`sed -n "/domain_4/s/.*=//p" namelist.modify | tr -d " "`
export domain_5=`sed -n "/domain_5/s/.*=//p" namelist.modify | tr -d " "`

if [[ $wholeonoff == 1 ]]; then
    ncl -Qn a.ncl
fi

if [[ $shapeonoff == 1 ]]; then
    myvar="path_to_shapefile"
    export shape_path=`sed -n "/$myvar/s/.*=//p" namelist.modify | tr -d " "`
    unset myvar
fi

domain_1=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d01_2021-01-22_00:00:00
domain_2=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d02_2021-01-22_00:00:00
domain_3=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d03_2021-01-22_00:00:00