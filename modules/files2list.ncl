file_list = NewList("lifo")
dom111file=getenv("domain_1")
if (fileexists(dom111file)) then
ListAppend(file_list, addfile(dom111file, "w"))
else
    print("Error!")
    print(dom111file + " is not a valid file for domain 1")
    exit()
end if
dom222file = getenv("domain_2")
if (fileexists(dom222file)) then
    ListAppend(file_list, addfile(dom222file, "w"))
else
    ListAppend(file_list, "no_file")
end if
dom333file = getenv("domain_3")
if (fileexists(dom333file)) then
    ListAppend(file_list, addfile(dom333file, "w"))
else
    ListAppend(file_list, "no_file")
end if
dom444file = getenv("domain_4")
if (fileexists(dom444file)) then
    ListAppend(file_list, addfile(dom444file, "w"))
else
    dom444 = "no_file"
end if
dom555file = getenv("domain_5")
if (fileexists(dom555file)) then
    ListAppend(file_list, addfile(dom555file, "w"))
else
    ListAppend(file_list, "no_file")
end if

d1 = str_squeeze(dom111file)
d2 = str_squeeze(dom222file)
d3 = str_squeeze(dom333file)
d4 = str_squeeze(dom444file)
d5 = str_squeeze(dom555file)

if (((d1 .eq. d2) .and. (d2 .ne. "")) .or. ((d2 .eq. d3) .and. (d2 .ne. "")) .or. ((d1 .eq. d3) .and. (d3 .ne. ""))) then
    print("Warning: Some domains in namelist.tailor have the same WRF file")
    print("Exiting ..")
    exit()
end if
