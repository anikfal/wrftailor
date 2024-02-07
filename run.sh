#!/bin/bash

# cat namelist_whole_domain.input | sed -n '2s/.*=//'
sed -n '/Variable/s/.*=//p' namelist.modify | tr -d " "

domain_1=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d01_2021-01-22_00:00:00
domain_2=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d02_2021-01-22_00:00:00
domain_3=/home/anikfal/extra_codes/SR/emissions/wrfchemi/wrfchemi_d03_2021-01-22_00:00:00
