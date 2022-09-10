chmod +x ./GBS-SNP-CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-9.pl

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-1.pl -d SE -b SNP_crop_barcode.txt -fq FileNameSeed -s 1 -e 4 -enz1 CAGC -enz2 CTGC -t 10

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-2.pl -tm ./Trimmomatic-0.39/trimmomatic-0.39.jar -d SE -fq ./parsed/FileNameSeed -t 10 -ph 33 -ad 0 -l 30 -sl 4:30 -tr 30 -m 32

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-3.pl -d SE -b SNP_crop_barcode_no_redun.txt -fq ./parsed/FileNameSeed

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-4.pl -vs vsearch-2.15.1/bin/vsearch -d SE -b SNP_crop_barcode_no_redun.txt -rl 100 -t 12 -cl consout -id 0.93 -db 1 -min 32 -MR GSC.MR

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-5.pl -bw ./bwa_0.7.17/bwa -st ./samtools-1.11/samtools -d SE -b SNP_crop_barcode_no_redun.txt -ref GSC.MR.Genome.fa -Q 30 -q 0 -F 2308 -f 0 -t 10 -opt 0

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-6.pl -b SNP_crop_barcode_no_redun.txt -out GSC.MasterMatrix.txt -t 12 

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-7.pl -in GSC.MasterMatrix.txt -out GSC.GenoMatrix.txt -mnHoDepth0 5 -mnHoDepth1 10 -mnHetDepth 3 -altStrength 0.8 -mnAlleleRatio 0.25 -mnCall 0.75 -mnAvgDepth 3 -mxAvgDepth 100

perl ./GBS_SNP_CROP/GBS-SNP-CROP-scripts/v.4.1/GBS-SNP-CROP-8.pl -in ./variants/GSC.GenoMatrix.txt -out GSC -b SNP_crop_barcode_no_redun.txt -formats Tassel

#this inserts a return after each line to make it so the vcf can be read properly after the pipeline
#sed 's/ /\t/g' GSC.vcf > GSC_edit.vcf
