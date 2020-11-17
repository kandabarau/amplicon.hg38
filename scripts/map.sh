#!/bin/bash

# map and remove chimeric reads

f1=$1
f2=$2
sm=$3
lb=${sm}
REF=$4
ct=ct

fc=$(zcat ${f1} | head -1 | cut -d':' -f3)
ln=$(zcat ${f2} | head -1 | cut -d':' -f4)

bwa mem -K 100000000 -v 3 -t 16 -Y -R "@RG\tID:${fc}.${ln}\tSM:${sm}\tLB:${sm}\tPL:illumina\tPU:${fc}.${lb}.${ln}\tCN:${ct}" ${REF} ${f1} ${f2} > ${sm}_bwamem.bam

samtools sort -o ${sm}.srt.bam ${sm}_bwamem.bam
samtools index ${sm}.srt.bam ${sm}.srt.bam.bai
