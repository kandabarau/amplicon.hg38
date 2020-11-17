#!/bin/bash

# Script to leave only proper fragments sequenced in bam

bm=$1 # input bam
fr=$2 # targets.bed
dp=$3 # minimal number of reads supporting the fragment

sm=$(samtools view -H ${bm} | grep '^@RG' | sed 's/.*SM://' | cut -f1 | uniq)

samtools view ${bm} | grep -v -e 'XA:Z:' -e 'SA:Z:' > ${sm}.uniq.aln
cut -f3,4,8,9 ${sm}.uniq.aln | sort | uniq -c | sort -nr | grep -v '*' | sed -e 's/ chr/\tchr/g' -e 's/ //g' | awk -v dp=${dp} '$1 >= dp' > ${sm}.seq.fragments
awk 'FNR==NR{a[$1,$2]; next} ($2,$3) in a' ${fr} ${sm}.seq.fragments | cut -f2,3,4,5 > ${sm}.trg.fragments
awk 'FNR==NR{a[$1,$2]; next} ($2,$4) in a' ${fr} ${sm}.seq.fragments | cut -f2,3,4,5 >> ${sm}.trg.fragments

samtools view -H ${bm} > ${sm}.filter.sam
awk 'FNR==NR{a[$1,$2,$3,$4]; next} ($3,$4,$8,$9) in a' ${sm}.trg.fragments ${sm}.uniq.aln >> ${sm}.filter.sam
samtools view -hb ${sm}.filter.sam | samtools sort -o ${sm}.filter.bam -
samtools index ${sm}.filter.bam

rm ${sm}.uniq.aln
rm ${sm}.filter.sam
