#!/bin/bash

echo ""
echo "Running Cone Generator..."
echo $@
echo ""

heightAndRadius=$1
volAndLat=$2
csvFile=$3
pngFile=$4

# cone calculations
docker_run="docker run --rm -i -v `pwd`:/scratch -w /scratch -u 0:0 avidalto/python_stl:v1"
$docker_run python3 "models/coneGenerator/createCone.py" $heightAndRadius $volAndLat "cone.stl"

# extract metrics
docker_run="docker run --rm --user root -i -v `pwd`:/scratch -w /scratch parallelworks/openfoam:4.1_paraview" 
$docker_run /bin/bash models/mexdex/extract.sh "cone.stl" $csvFile $pngFile

echo "Cone Creation Complete."