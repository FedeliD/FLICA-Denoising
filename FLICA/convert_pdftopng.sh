#!/bin/sh

for i in $(seq 0 30); do

echo $i
convert correlation_${i}_age.eps correlation_${i}_age.png
convert correlation_${i}_sex.eps correlation_${i}_sex.png
convert correlation_${i}_onset.eps correlation_${i}_onset.png
convert correlation_${i}_grams.eps correlation_${i}_grams.png
convert correlation_${i}_dur.eps correlation_${i}_dur.png
convert correlation_${i}_CM.eps correlation_${i}_CM.png

done