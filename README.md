# truseq.hg38
illumina truseq panel run on better controlled and free tools

Primer sequences in illumina reads introduce wt bias into variant calling (within overlapping amplicons). This issue is addressed in Illumina built-in software. In order to process reads outside of truseq-aware tools we need to reproduce that behaivour.

![primer regions imported and marked red in regions pannel](https://github.com/kandabarau/truseq.hg38/blob/main/img/igv.primer.softclip.JPG)

First, we need to [re-format](https://github.com/tommyau/bamclipper/blob/master/scripts/manifest2bedpe.pl) truseq manifest file to bedpe 

`scripts/manifest2bedpe.pl < Manifest.hg19.txt | sed 's/ /_/g' | bedtools sort > Manifest.hg19.bedpe`

Then - [lift it over](https://github.com/dphansti/liftOverBedpe/blob/master/liftOverBedpe.py) to hg38

`python liftOverBedpe.py --lift ./liftOver --chain hg19ToHg38.over.chain.gz --i Manifest.hg19.bedpe --o Manifest.hg38.bedpe  --h F`

And keep genomic targets (for variant calling) and their primers (for IGV) in separate .bed*s*

`awk -v s=1 'BEGIN {OFS = "\t"}; {print $1, $3+s, $5-s, $7}' Manifest.hg38.bedpe > Manifest.hg38.targets.bed`

`awk 'BEGIN {OFS = "\t"}; {print $1, $2, $3, $7}; {print $1, $5, $6, $7}' Manifest.hg38.bedpe > Manifest.hg38.primers.bed`

Then we have everything ready to [softclip](https://github.com/tommyau/bamclipper/blob/master/bamclipper.sh) primer bases from a sorted hg38 BAM

`./bamclipper.sh -b hg38.srt.bam -p Manifest.hg38.bedpe -n 4`
