#!/bin/bash

# map to the reference of choice

f1=$1
f2=$2
sm=$3
lb=${sm}
REF=$4
ct=ct

fc=$(zcat ${f1} | head -1 | cut -d':' -f3)
ln=$(zcat ${f2} | head -1 | cut -d':' -f4)

if [ ! -e "${sm}_bwamem.bam" ]
then
bwa mem -v 1 -t 16 -Y -R "@RG\tID:${fc}.${ln}\tSM:${sm}\tLB:${sm}\tPL:illumina\tPU:${fc}.${lb}.${ln}\tCN:${ct}" ${REF} ${f1} ${f2} > ${sm}_bwamem.bam
fi

samtools sort -o ${sm}.srt.bam ${sm}_bwamem.bam
samtools index ${sm}.srt.bam ${sm}.srt.bam.bai
