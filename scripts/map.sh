#!/bin/bash

set -e

# map to the reference of choice

f1=$1 # read 1
f2=$2 # read 2
sm=$3 # sample
lb=${sm} # library, specify if differs from sample. not in our case
REF=$4 # reference fasta
ct=ct # sequening center, specify here
bmdir=$5 # dir to write the alignments

fc=$(zcat ${f1} | head -1 | cut -d':' -f3)
ln=$(zcat ${f2} | head -1 | cut -d':' -f4)

bwa mem -v 1 -t 16 -Y -R "@RG\tID:${fc}.${ln}\tSM:${sm}\tLB:${sm}\tPL:illumina\tPU:${fc}.${lb}.${ln}\tCN:${ct}" ${REF} ${f1} ${f2} > ${bmdir}${sm}_bwamem.bam

samtools sort -o ${bmdir}${sm}.srt.bam ${bmdir}${sm}_bwamem.bam
samtools index ${bmdir}${sm}.srt.bam ${bmdir}${sm}.srt.bam.bai
