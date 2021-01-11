#!/bin/bash

# remove chimeric reads and reads from failed amplicon libraries

bmdir=$1 # dif witj alignemnts
bwamemed=$2 # raw bwa mem result with softclips
primerclipped=$3 # sorted bam with amplicon primers clipped
fragmens=$4 # amplicon targets bed

mkdir -p ${bmdir}readIDs/

sm=$(samtools view -H ${bmdir}${bwamemed} | grep '^@RG' | sed 's/.*SM://' | cut -f1 | uniq)

# we do not expect to have in our alignemnts

samtools view ${bmdir}${bwamemed} | awk '$6 ~ /H|S/{print $1}' | sort -t $'\t' -k1,1 -u > ${bmdir}readIDs/${sm}.clipped.reads

# let's see if reads in pairs both start at target regein's edges

samtools view ${bmdir}${primerclipped} | cut -f1,3,4,9 | awk 'FNR==NR{a[$1,$2,$5]; next} ($2,$3,$4) in a' ${fragments} - | cut -f1 | sort -t $'\t' -k1,1 -u > ${bmdir}readIDs/${sm}.targeted.reads
join -t $'\t' -v 1 -1 1 -2 1 ${bmdir}readIDs/${sm}.targeted.reads ${bmdir}readIDs/${sm}.clipped.reads > ${bmdir}readIDs/${sm}.good.reads

# split primerclipped bam into "good" and "bad" bams. to have a track of how our filer treaed the reads

mkdir -p ${bmdir}ftd/

samtools view ${bmdir}${primerclipped} | sort -t $'\t' -k1,1 > ${bmdir}${sm}.tmp.sam

samtools view -H ${bmdir}${primerclipped} > ${bmdir}${sm}.ftd.sam
join -t $'\t' -1 1 -2 1 ${bmdir}${sm}.tmp.sam ${bmdir}readIDs/${sm}.good.reads >> ${bmdir}${sm}.ftd.sam
samtools view -bS ${bmdir}${sm}.ftd.sam | samtools sort - > ${bmdir}ftd/${sm}.ftd.bam
samtools index ${bmdir}ftd/${sm}.ftd.bam ${bmdir}ftd/${sm}.ftd.bam.bai

mkdir -p ${bmdir}out/

samtools view -H ${bmdir}${primerclipped} > ${bmdir}${sm}.out.sam
join -t $'\t' -v 1 -1 1 -2 1 ${bmdir}${sm}.tmp.sam ${bmdir}readIDs/${sm}.good.reads >> ${bmdir}${sm}.out.sam
samtools view -bS ${bmdir}${sm}.out.sam | samtools sort - > ${bmdir}out/${sm}.out.bam
samtools index ${bmdir}out/${sm}.out.bam ${bmdir}out/${sm}.out.bam.bai

rm ${bmdir}${sm}*sam


