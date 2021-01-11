#!/bin/bash

# remove chimeric reads and reads from failed amplicon libraries

bwamemed=$1
primerclipped=$2
fragmens=$3

mkdir -p readIDs/

sm=$(samtools view -H ${bwamemed} | grep '^@RG' | sed 's/.*SM://' | cut -f1 | uniq)

# we do not expect to have in our alignemnts

samtools view ${bwamemed} | awk '$6 ~ /H|S/{print $1}' | sort -t $'\t' -k1,1 -u > readIDs/${sm}.clipped.reads

# let's see if reads in pairs both start at target regein's edges

samtools view ${primerclipped} | cut -f1,3,4,9 | awk 'FNR==NR{a[$1,$2,$5]; next} ($2,$3,$4) in a' ${fragments} - | cut -f1 | sort -t $'\t' -k1,1 -u > readIDs/${sm}.targeted.reads
join -t $'\t' -v 1 -1 1 -2 1 readIDs/${sm}.targeted.reads readIDs/${sm}.clipped.reads > readIDs/${sm}.good.reads

# split primerclipped bam into "good" and "bad" bams. to have a track of how our filer treaed the reads

mkdir -p ftd/

samtools view ${primerclipped}} | sort -t $'\t' -k1,1 > ${sm}.tmp.sam

samtools view -H ${primerclipped} > ${sm}.ftd.sam
join -t $'\t' -1 1 -2 1 ${sm}.tmp.sam readIDs/${sm}.good.reads >> ${sm}.ftd.sam
samtools view -bS ${sm}.ftd.sam | samtools sort - > ftd/${sm}.ftd.bam
samtools index ftd/${sm}.ftd.bam ftd/${sm}.ftd.bam.bai

mkdir -p out/

samtools view -H ${primerclipped} > ${sm}.out.sam
join -t $'\t' -v 1 -1 1 -2 1 ${sm}.tmp.sam readIDs/${sm}.good.reads >> ${sm}.out.sam
samtools view -bS ${sm}.out.sam | samtools sort - > out/${sm}.out.bam
samtools index out/${sm}.out.bam out/${sm}.out.bam.bai

rm ${sm}*sam


