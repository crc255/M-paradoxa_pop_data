#before you begin, make sure to convert this sh using dos2unix!!!!!!!!!!!
#nohup bash /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/m_paradoxa_master.sh &

#1:GBSSeqToTagDBPlugin() is the first step in the pipeline. It identifies tags from fastQ input files then stores these tags and the taxa in which they appear into a local SQLite database.
/mnt/c/Users/super/Documents/software/tassel_5_standalone/run_pipeline.pl -Xms5G -Xmx30G -fork1 -GBSSeqToTagDBPlugin \
-e ApeKI \
-i /mnt/d/gbs_raw_reads/ \
-db /mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/GBSV2_paradoxa.db \
-k /mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/barcode/paradoxa_barcode.txt \
-minKmerL 20 \
-mnQS 20 \
-mxKmerNum 100000000 \
-endPlugin -runfork1

#2:TagExportToFastqPlugin() is executed to pull distinct tags from the database and export them in the fastq format so that they can be aligned to the reference genome with various aligners 
/mnt/c/Users/super/Documents/software/tassel_5_standalone/run_pipeline.pl -fork1 -TagExportToFastqPlugin \
-db /mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/GBSV2_paradoxa.db \
-o /mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/tagsForAlign.fa.gz \
-c 1 \
-endPlugin -runfork1

#3 A biological sequence aligner must now run to align tags against a reference genome. GBSv2 supports the BWA and Bowtie2 alignment programs.
#BWA was chosen, index "Index database sequences in the FASTA format"
/mnt/c/Users/super/Documents/software/bwa/bwa index \
-a bwtsw /mnt/d/genomes/m_americana/for_bwa/m_paradoxa/Melame1_AssemblyScaffolds_Repeatmasked.fasta

#4 aln "Find the SA coordinates of the input reads."
/mnt/c/Users/super/Documents/software/bwa/bwa aln \
-t 4 /mnt/d/genomes/m_americana/for_bwa/m_paradoxa/Melame1_AssemblyScaffolds_Repeatmasked.fasta \
/mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/tagsForAlign.fa.gz > /mnt/c/Users/super/Desktop/PhD_2015_2021/GBS_paper/gbs_pop_work/m_paradoxa_paper_snp/8_7_22/tagsForAlign.sai

#5 samse "Generate alignments in the SAM format given single-end reads"
/mnt/c/Users/super/Documents/software/bwa/bwa samse /mnt/d/genomes/m_americana/for_bwa/m_paradoxa/Melame1_AssemblyScaffolds_Repeatmasked.fasta \
/mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/tagsForAlign.sai \
/mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/tagsForAlign.fa.gz > /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/tagsForAlign.sam 

#6 SAMToGBSdbPlugin reads a SAM file to determine the potential positions of Tags against the reference genome. The plugin updates the current database with information on tag cut positions. It will throw an error if there are tags found in the SAM file that can not be matched to tags in the database.
/mnt/c/Users/super/Documents/software/tassel_5_standalone/run_pipeline.pl -fork1 -SAMToGBSdbPlugin \
-i /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/tagsForAlign.sam  \
-db /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/GBSV2_paradoxa.db \
-aProp 0.0 \
-aLen 0 \
-endPlugin -runfork1

#7 DiscoverySNPCallerPlugin() is then used to identify SNPs from aligned tags using the GBS DB.
/mnt/c/Users/super/Documents/software/tassel_5_standalone/run_pipeline.pl -fork1 -DiscoverySNPCallerPluginV2 \
-db /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/GBSV2_paradoxa.db \
-Xmx16G \
-mnLCov 0.1 \
-mnMAF 0.01 \
-deleteOldData true \
-endPlugin -runfork1

#8 This plugin converts data from fastq and keyfile to genotypes, then adds these to a genotype file in VCF or HDF5 format. VCF is the default output. An HDF5 file may be requested by using the suffix ".h5" on the file used in the output file parameter. Merging of samples to the same HDF5 output file may be accomplished by using the –ko option described below.
/mnt/c/Users/super/Documents/software/tassel_5_standalone/run_pipeline.pl -fork1 -ProductionSNPCallerPluginV2 \
-Xmx16G \
-db /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/GBSV2_paradoxa.db \
-e ApeKI \
-i /mnt/d/gbs_raw_reads/ \
-k /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/barcode/paradoxa_barcode.txt \
-kmerLength 64 \
-o /mnt/c/Users/super/Documents/gbs_pop_work/m_paradoxa_paper_snp/2_3_21/m_paradoxa_no_filt.vcf \
-endPlugin -runfork1

