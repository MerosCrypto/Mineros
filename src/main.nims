#Use C++ instead of C.
setCommand("cpp")

#Necessary flags.
switch("threads", "on")

#Optimize for size.
switch("opt", "size")

#Define release for usable StInt performance.
switch("define", "release")

#Enable stackTrace and lineTrace so users can submit workable crash reports.
switch("stackTrace", "on")
switch("lineTrace", "on")

#Disable checks (which also disables assertions).
switch("checks", "off")

#Enable hints.
switch("hints", "on")

#Enable parallel building.
switch("parallelBuild", "0")

#Specify where to output built objects.
switch("nimcache", "build/nimcache")
switch("out", "build/Mineros")

when defined(merosRelease):
    #Disable finals.
    switch("define", "finalsOff")

    #Disable extra debug info.
    switch("excessiveStackTrace", "off")
    switch("lineDir", "off")
else:
    #Enable finals.
    switch("define", "finalsOn")

    #Enable extra debug info.
    switch("debuginfo")
    switch("excessiveStackTrace", "on")
    switch("lineDir", "on")
