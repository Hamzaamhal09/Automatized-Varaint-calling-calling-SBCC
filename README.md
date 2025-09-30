# Pipeline Overview

This repository contains a preliminary release of an automated variant-calling pipeline.

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




You can first downod the whole repository using

```
git clone https://github.com/Hamzaamhal09/Automatized-Varaint-calling-calling-SBCC.git

```

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

    Imputation and Phasing (upcoming)




# instalation guide 

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



