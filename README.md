# Pipeline Overview

This repository contains a preliminary release of an automated variant-calling pipeline using GATK.

The pipeline can be executed in several ways:

- Full run: Execute the entire workflow using the provided .smk (Snakemake) file.

- Stepwise execution: Run specific steps by selecting them directly from the .smk file.

- Direct execution: Run each component individually using the corresponding scripts in the scripts/ directory.

# Test Dataset

To facilitate testing, the repository includes a small dataset in the data/ folder. This dataset is designed to run on a standard laptop with at least 16 GB of RAM.

Files included:

- A_1_20_1.fastq.gz – Example paired-end read (R1).

- A_1_20_2.fastq.gz – Example paired-end read (R2).

- barley_test_7chr_60Mb.fa – A reduced reference genome derived from barley MorexV3.

The first 60 Mb of each chromosome was extracted to create a simplified “mini-genome” for quick testing.

Since GATK requires an even number of chromosomes, each chromosome was split into two parts. In this test case, barley (7 chromosomes) was converted into 14 pseudo-chromosomes.For other species, this step may not be necessary.



# Installation

To get started, first download the entire repository by cloning it:


```

git clone https://github.com/Hamzaamhal09/Automatized-Varaint-calling-calling-SBCC.git

```
Then move into the project directory:

```
cd Automatized-Varaint-calling-calling-SBCC

```

Before running the pipeline, you need to install **Conda** and **Snakemake**

- [Conda installation guide for Linux](https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html)  
-  [Snakemake official installation instructions](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)

After installing Conda, create a new environment for Snakemake (as mentioned in the tutorial) with :

```
conda create -c conda-forge -c bioconda -n snakemake snakemake
```
 we need to install **yq** a command-line tool for parsing and manipulating YAML files, used to read values from the configuration files in the scripts.

```
conda install -c conda-forge yq
```

Install **FastQC** and **MultiQC** to analyse the sequence read quality

```
conda install -c bioconda fastqc
conda install -c bioconda multiqc

```

Install **bwa-mem2** and **samtools** for read mapping and BAM file processing:bcftools

```
conda install -c bioconda bwa-mem2 samtools
```

Install **Picard** , to run Picard we also need **Java** (OpenJDK) (we need at least **version 17**)

```
conda install -c conda-forge openjdk=17
conda install -c bioconda picard

```
Install **GATK** for variant calling :
```
wget -q https://github.com/broadinstitute/gatk/releases/download/4.6.2.0/gatk-4.6.2.0.zip && unzip -q gatk-4.6.2.0.zip

```

Install **bcftools** :

```
conda install -c bioconda bcftools

```


# Quick Overview

the snakemakepipline.smk script performs the full variant discovery workflow using GATK haplotype caller :

    check_quality
    Runs a script to assess read quality and produces a completion flag file.

    map_reads
    Maps reads to the reference genome using a bash script and creates a completion marker.

    mark_duplicates
    Identifies and marks duplicate reads in the BAM files.

    variant_calling
    Calls variants for each sample using GATK's HaplotypeCaller.

    genotype_all
    Performs joint genotyping across all variant call files.

    combine_chr_update_coordinates
    Merges per-chromosome VCFs and updates coordinates accordingly.

    filter_vcf
    Applies quality-based filtering to the final VCF files.


# Run the full pipeline

First Enter to the info_files directory:

```
cd info_files
```

Check the contents of the directory: you will find 5 different files that need to be customized in order to run the pipeline with your own data.
```
ls
bedfile_fullchr.bed  cohort.sample_map.list  INFO_FILE_FINAL.txt  interval2.list  Variant_calling_list.txt

```

- INFO_FILE_FINAL.txt file is essential for mapping the reads to our reference genome it defines the sequenced samples and its associated metadata for the pipeline



```
ST459_174:1 A_1_20 ST459_174:1 ILUMINA SBCC056 data/A_1_20_1.fastq.gz data/A_1_20_2.fastq.gz
```

- Sample ID / Read group – ST459_174:1

    - Short sample name – A_1_20

    - Read group ID – ST459_174:1

    - Sequencing platform – ILUMINA

    - Sample Name – SBCC056

    - FASTQ file (R1) – data/A_1_20_1.fastq.gz

    - FASTQ file (R2) – data/A_1_20_2.fastq.gz




- bedfile_fullchr.bed file is essentially a chromosome-splitting table that defines how each chromosome is divided into parts for the pipeline


```
chr1H_part1 0 30000000 chr1H 0 30000000
chr1H_part2 0 30000000 chr1H 30000000 60000000
chr2H_part1 0 30000000 chr2H 0 30000000
chr2H_part2 0 30000000 chr2H 30000000 60000000
chr3H_part1 0 30000000 chr3H 0 30000000
chr3H_part2 0 30000000 chr3H 30000000 60000000
chr4H_part1 0 30000000 chr4H 0 30000000
chr4H_part2 0 30000000 chr4H 30000000 60000000
chr5H_part1 0 30000000 chr5H 0 30000000
chr5H_part2 0 30000000 chr5H 30000000 60000000
chr6H_part1 0 30000000 chr6H 0 30000000
chr6H_part2 0 30000000 chr6H 30000000 60000000
chr7H_part1 0 30000000 chr7H 0 30000000
chr7H_part2 0 30000000 chr7H 30000000 60000000

```
```
<segment_name> <start_offset> <length> <chromosome_name> <chrom_start> <chrom_end>
```
   - segment_name – Name of the chromosome segment (e.g., chr1H_part1).

   - start_offset – Offset within the segment (usually 0 for all segments).

   - length – Length of the segment (e.g., 30000000 bases).

   - chromosome_name – Original chromosome name from the reference (e.g., chr1H).

   - chrom_start – Start position on the reference chromosome.

   - chrom_end – End position on the reference chromosome.



```

```

```

```

```

```

```

```









From the project root directory, run:

```
snakemake -s snakemakepipline.smk --cores 4

```

Run individual steps

You can also run a specific step (rule) only:

```
snakemake -s snakemakepipline.smk <rule_name> --cores 4

```


For example:

```
snakemake -s snakemakepipline.smk map_reads --cores 4

```



