#!/bin/bash

# Script to leave only proper fragments sequenced in bam

bm=$1 # input bam
fr=$2 # targets.bed

sm=$(samtools view -H ${bm} | grep '^@RG' | sed 's/.*SM://' | cut -f1 | uniq)

mkdir -p fragments/
mkdir -p filter/
mkdir -p out/

# get uniquely aligned well target reads

samtools view ${bm} | grep -v -e 'XA:Z:' -e 'SA:Z:' > ${sm}.uniq.aln
cut -f3,4,8,9 ${sm}.uniq.aln | sort | uniq -c | sort -nr | grep -v '*' | sed -e 's/ chr/\tchr/g' -e 's/ //g' > fragments/${sm}.seq.fragments
awk 'FNR==NR{a[$1,$2,$5]; next} ($2,$3,$5) in a' ${fr} fragments/${sm}.seq.fragments | cut -f2,3,4,5 > fragments/${sm}.trg.fragments
awk 'FNR==NR{a[$1,$2,$5*=-1]; next} ($2,$4,$5) in a' ${fr} fragments/${sm}.seq.fragments | cut -f2,3,4,5 >> fragments/${sm}.trg.fragments

samtools view -H ${bm} > ${sm}.filter.sam
awk 'FNR==NR{a[$1,$2,$3,$4]; next} ($3,$4,$8,$9) in a' fragments/${sm}.trg.fragments ${sm}.uniq.aln >> ${sm}.filter.sam
samtools view -hb ${sm}.filter.sam | samtools sort -o filter/${sm}.filter.bam -
samtools index filter/${sm}.filter.bam filter/${sm}.filter.bam.bai 

# get non-uniquely aligned or poor target reads

awk 'FNR==NR{a[$1,$2,$3,$4]; next} !($2,$3,$4,$5) in a' fragments/${sm}.trg.fragments fragments/${sm}.seq.fragments | cut -f2,3,4,5 > fragments/${sm}.out.fragments

samtools view -H ${bm} > ${sm}.out.sam
samtools view ${bm} | grep -e 'XA:Z:' -e 'SA:Z:' >> ${sm}.out.sam
awk 'FNR==NR{a[$1,$2,$3,$4]; next} ($3,$4,$8,$9) in a' fragments/${sm}.out.fragments ${sm}.uniq.aln >> ${sm}.out.sam
samtools view -hb ${sm}.out.sam | samtools sort -o out/${sm}.out.bam -
samtools index out/${sm}.out.bam out/${sm}.out.bam.bai

rm ${sm}.uniq.aln
rm ${sm}.filter.sam
rm ${sm}.out.sam

