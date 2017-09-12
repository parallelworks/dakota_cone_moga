#!/bin/bash

heightAndRadius="height,1,radius,1"
volAndLat="results/volAndLat.txt"
csvFile="results/metrics.csv"
pngFile="results/out_cone.png"

mkdir results > /dev/null 1>&1

/bin/bash "coneGenerator/createCone.sh" $heightAndRadius $volAndLat $csvFile $pngFile
