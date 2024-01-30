cc=addfile("wrfchemi_d03_2021-01-22_00:00:00", "r")
bb=addfile("wrfchemi_d02_2021-01-22_00:00:00", "r")
aa=addfile("wrfchemi_d01_2021-01-22_00:00:00", "r")
cc_lat = cc->XLAT
cc_lon = cc->XLONG
bb_lat = bb->XLAT
bb_lon = bb->XLONG
aa_lat = aa->XLAT
aa_lon = aa->XLONG

printMinMax(cc_lat, 0)
printMinMax(bb_lat, 0)
printMinMax(aa_lat, 0)

;https://www.ncl.ucar.edu/Document/Functions/Built-in/triple2grid2d.shtml