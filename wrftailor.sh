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
    echo "  Warning: No section is activated"
    echo "  Select one task or section in namelist.wrf and run again"
    exit
fi
function countline() {
  numlinevars=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | awk -F',' '{ print NF }')
  ifendcomma=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | awk -F "," '{print $NF}' | tr -d " ")
  if [[ $ifendcomma == "" ]]; then
    numlinevars=$((numlinevars - 1))
  fi
  }
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

if [[ $pointsonoff == 1 ]]; then
  export wrf_variable=$(sed -n "/variable_name3/s/.*=//p" namelist.tailor | tr -d " ")
  myvar="point_values"
  countline
  export nclpoints=$numlinevars #Zero (0) is included in the line numbers
  #Extracting Variables into array
  varcount=0
  while [ $varcount -lt $nclpoints ]; do
    locpoints[$varcount]=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | cut -d, -f$((varcount + 1)))
    locpoints[$varcount]=$(echo ${locpoints[$varcount]}) #Remove spaces
    varcount=$((varcount + 1))
  done
  unset varcount

  varcount=0
  while [ $varcount -lt $nclpoints ]; do
    declare ncllocpoints$varcount=${locpoints[$varcount]}
    export ncllocpoints$varcount
    varcount=$((varcount + 1))
  done
  unset myvar

  myvar="latitudes_list"
  countline
  export ncllats=$numlinevars #Zero (0) is included in the line numbers
  #Extracting Variables into array
  varcount=0
  while [ $varcount -lt $ncllats ]; do
    loclats[$varcount]=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | cut -d, -f$((varcount + 1)))
    loclats[$varcount]=$(echo ${loclats[$varcount]}) #Remove spaces
    varcount=$((varcount + 1))
  done
  unset varcount

  varcount=0
  while [ $varcount -lt $ncllats ]; do
    declare nclloclats$varcount=${loclats[$varcount]}
    export nclloclats$varcount
    varcount=$((varcount + 1))
  done
  unset myvar

    myvar="longitudes_list"
  countline
  ncllons=$numlinevars #Zero (0) is included in the line numbers
  if [[ $ncllats -ne $ncllons || $ncllons -ne $nclpoints ]]; then
    echo "Warning: Number of elements for latitudes_list, longitudes_list, and point_values are $ncllats, $ncllons, and $nclpoints. But they must be equal."
    echo Exiting ..
    exit
  fi

  #Extracting Vairables into array
  varcount=0
  while [ $varcount -lt $ncllons ]; do
    loclons[$varcount]=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | cut -d, -f$((varcount + 1)))
    loclons[$varcount]=$(echo ${loclons[$varcount]}) #Remove spaces
    varcount=$((varcount + 1))
  done
  unset varcount

  varcount=0
  while [ $varcount -lt $ncllons ]; do
    declare nclloclons$varcount=${loclons[$varcount]}
    export nclloclons$varcount
    varcount=$((varcount + 1))
  done
  unset myvar

    echo $wrf_new_variable >$app_dir"/modules/totalequation.txt"
    cd $app_dir/modules
    ncl separation.ncl >/dev/null
    filename="bounding.ncl"
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
    ncl -Qn points.ncl
fi

if [[ $wholeonoff == 1 ]]; then
    export wrf_variable=$(sed -n "/variable_name4/s/.*=//p" namelist.tailor | tr -d " ")
    export wrf_new_variable=$(sed -n "/variable_substitute_name4/s/.*=//p" namelist.tailor | tr -d " ")
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
    export wrf_variable=$(sed -n "/variable_name1/s/.*=//p" namelist.tailor | tr -d " ")
    export variable_level=$(sed -n "/variable_level1/s/.*=//p" namelist.tailor | tr -d " ")
    wrf_new_variable=$(sed -n "/variable_substitute_name1/s/.*=//p" namelist.tailor | tr -d " ")
    export inverse_mask_on_off=$(awk_read_onoff inverse_mask_on_off)
    myvar="variable_substitute_levels1"
    countline
    export substitutenumber=$numlinevars #Zero (0) is included in the line numbers
    #Extracting Variables into array
    varcount=0
    while [ $varcount -lt $substitutenumber ]; do
      sublevels[$varcount]=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | cut -d, -f$((varcount + 1)))
      sublevels[$varcount]=$(echo ${sublevels[$varcount]}) #Remove spaces
      varcount=$((varcount + 1))
    done
    varcount=0
    while [ $varcount -lt $substitutenumber ]; do
      declare sublevels$varcount=${sublevels[$varcount]}
      export sublevels$varcount
      varcount=$((varcount + 1))
    done

    echo $wrf_new_variable >$app_dir"/modules/totalequation.txt"
    cd $app_dir/modules
    ncl separation.ncl >/dev/null
    filename="shapefile.ncl"
    filename_copy=$filename"_copy"
    sed '/added_new_line_by_sed/ d' $filename >$filename_copy #cleaning previous vars added by sed
    mv $filename_copy $filename                               #recycling the code to its prestine condition
    count=$(cat variables.txt | wc -l)
    mm=0
    while [ $mm -lt $count ]; do
        onevar[$mm]=$(sed -n "$((mm + 1)) p" variables.txt)
        sed '/shell script/a \
          '${onevar[$mm]}' := varlist['$mm']  ;;;added_new_line_by_sed \
          vardim := dimsizes('${onevar[$mm]}') ;;;added_new_line_by_sed \
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed \
            dimnames = getvardims('${onevar[$mm]}') ;;;added_new_line_by_sed \
            if ((sublevels('$mm') .gt. (vardim(1)-1)) .or. (sublevels('$mm') .lt. 0)) then ;;;added_new_line_by_sed \
              selected_sublevel = sublevels('$mm')+1 ;;;added_new_line_by_sed \
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames('$mm') + \\ ;;;added_new_line_by_sed \
              " (" + '${onevar[$mm]}'@description + ") in namelist.tailor is " + selected_sublevel + \\ ;;;added_new_line_by_sed \
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed \
              print("Exiting ..") ;;;added_new_line_by_sed \
              exit() ;;;added_new_line_by_sed \
            end if ;;;added_new_line_by_sed \
            '${onevar[$mm]}' := '${onevar[$mm]}'(:, sublevels('$mm'), :, :) ;;;added_new_line_by_sed \
          end if ;;;added_new_line_by_sed' $filename >$filename_copy
        mv $filename_copy $filename
        mm=$((mm + 1))
    done
    equation=$(cat totalequation.txt)
    sed '/equation from namelist.wrf/ a polynomial := '$equation'  ;;;added_new_line_by_sed' $filename >$filename_copy
    mv $filename_copy $filename
    ncl -Qn shapefile.ncl
fi

if [[ $boundonoff == 1 ]]; then
    export north_lat=$(sed -n "/north_lat/s/.*=//p" namelist.tailor | tr -d " ")
    export south_lat=$(sed -n "/south_lat/s/.*=//p" namelist.tailor | tr -d " ")
    export west_long=$(sed -n "/west_long/s/.*=//p" namelist.tailor | tr -d " ")
    export east_long=$(sed -n "/east_long/s/.*=//p" namelist.tailor | tr -d " ")
    export wrf_new_variable=$(sed -n "/variable_substitute_name2/s/.*=//p" namelist.tailor | tr -d " ")
    export wrf_variable=$(sed -n "/variable_name2/s/.*=//p" namelist.tailor | tr -d " ")
    export variable_level=$(sed -n "/variable_level2/s/.*=//p" namelist.tailor | tr -d " ")
    myvar="variable_substitute_levels2"
    countline
    export substitutenumber=$numlinevars #Zero (0) is included in the line numbers
    #Extracting Variables into array
    varcount=0
    while [ $varcount -lt $substitutenumber ]; do
      sublevels[$varcount]=$(sed -n "/$myvar/p" namelist.tailor | awk -F"=" '{print $NF}' | cut -d, -f$((varcount + 1)))
      sublevels[$varcount]=$(echo ${sublevels[$varcount]}) #Remove spaces
      varcount=$((varcount + 1))
    done
    varcount=0
    while [ $varcount -lt $substitutenumber ]; do
      declare sublevels$varcount=${sublevels[$varcount]}
      export sublevels$varcount
      varcount=$((varcount + 1))
    done
    
    echo $wrf_new_variable >$app_dir"/modules/totalequation.txt"
    cd $app_dir/modules
    ncl separation.ncl >/dev/null
    filename="bounding.ncl"
    filename_copy=$filename"_copy"
    sed '/added_new_line_by_sed/ d' $filename >$filename_copy #cleaning previous vars added by sed
    mv $filename_copy $filename                               #recycling the code to its prestine condition
    count=$(cat variables.txt | wc -l)
    mm=0
    while [ $mm -lt $count ]; do
        onevar[$mm]=$(sed -n "$((mm + 1)) p" variables.txt)
        sed '/shell script/a \
          '${onevar[$mm]}' := varlist['$mm']  ;;;added_new_line_by_sed \
          vardim := dimsizes('${onevar[$mm]}') ;;;added_new_line_by_sed \
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed \
            dimnames = getvardims('${onevar[$mm]}') ;;;added_new_line_by_sed \
            if ((sublevels('$mm') .gt. (vardim(1)-1)) .or. (sublevels('$mm') .lt. 0)) then ;;;added_new_line_by_sed \
              selected_sublevel = sublevels('$mm')+1 ;;;added_new_line_by_sed \
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames('$mm') + \\ ;;;added_new_line_by_sed \
              " (" + '${onevar[$mm]}'@description + ") in namelist.tailor is " + selected_sublevel + \\ ;;;added_new_line_by_sed \
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed \
              print("Exiting ..") ;;;added_new_line_by_sed \
              exit() ;;;added_new_line_by_sed \
            end if ;;;added_new_line_by_sed \
            '${onevar[$mm]}' := '${onevar[$mm]}'(:, sublevels('$mm'), :, :) ;;;added_new_line_by_sed \
          end if ;;;added_new_line_by_sed' $filename >$filename_copy
        mv $filename_copy $filename
        mm=$((mm + 1))
    done
    equation=$(cat totalequation.txt)
    sed '/equation from namelist.wrf/ a polynomial := '$equation'  ;;;added_new_line_by_sed' $filename >$filename_copy
    mv $filename_copy $filename
    # exit
    ncl -Qn bounding.ncl
fi

if [[ $geotiffonoff == 1 ]]; then
    gdal_translate --version >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Warning: gdal_translate must be installed on the system."
        echo "Exiting ..."
        exit
    fi
    export geotiff_file=$(sed -n "/geotiff_file/s/.*=//p" namelist.tailor | tr -d " ")
    export wrf_variable=$(sed -n "/variable_name5/s/.*=//p" namelist.tailor | tr -d " ")
    cd $app_dir/modules
    filename=$(basename $geotiff_file)
    export tiff2nc=$filename".nc"
    echo "Converting GeoTIFF to NetCDF ..."
    gdal_translate -of NetCDF $geotiff_file $tiff2nc
    ncl -Q geotiff.ncl
fi