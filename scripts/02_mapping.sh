#!/bin/bash

# Load config from YAML using yq
CONFIG_FILE="config/config_paths.yaml"  # Adjust if needed

reference_genome=$(yq -r ".reference_genome" "$CONFIG_FILE")
info_file=$(yq -r '.info_file' "$CONFIG_FILE")
bam_dir=$(yq -r '.bam_dir' "$CONFIG_FILE")
flagstat_dir=$(yq -r '.flagstat_dir' "$CONFIG_FILE")
index_dir=$(yq -r '.index_dir' "$CONFIG_FILE")
idxstats_dir=$(yq -r '.idxstats_dir' "$CONFIG_FILE")
threads=$(yq -r '.threads' "$CONFIG_FILE")


# -----------------------------
# Make paths absolute relative to the script folder
# Make absolute paths
# -----------------------------
# Get the project root directory (one level up from the scripts folder)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Prepend PROJECT_DIR to all relative paths to make them absolute
reference_genome=$PROJECT_DIR/$reference_genome
info_file=$PROJECT_DIR/$info_file
bam_dir=$PROJECT_DIR/$bam_dir
flagstat_dir=$PROJECT_DIR/$flagstat_dir
index_dir=$PROJECT_DIR/$index_dir
idxstats_dir=$PROJECT_DIR/$idxstats_dir



# -----------------------------




# Print variables
echo "Reference: $reference_genome"
echo "Info file: $info_file"
echo "Threads: $threads"

# Create output directories if they don't exist
mkdir -p $bam_dir
mkdir -p $flagstat_dir
mkdir -p $index_dir
mkdir -p $idxstats_dir

# Index the reference genome
#bwa index "$reference_genome"

# Mapping loop
cat "$info_file" | while read -r ids ori_name pu pl sm reads1 reads2
do
    # Convert FASTQ paths to absolute
    reads1="$PROJECT_DIR/$reads1"
    reads2="$PROJECT_DIR/$reads2"

    # BWA-MEM2 mapping and sorting to BAM
    bwa mem \
        -t "$threads" \
        -R "@RG\tID:$ids\tSM:$sm\tPL:$pl\tLB:$sm" "$reference_genome" \
        <(zcat "$reads1") \
        <(zcat "$reads2") | \
    samtools view -bS | \
    samtools sort -@ "$threads" -o "$bam_dir/$sm.sort.bam" && \

    # Generate flagstat
    samtools flagstat "$bam_dir/$sm.sort.bam" > "$flagstat_dir/$sm.flagstat.txt" && \

    # Index BAM file
    samtools index "$bam_dir/$sm.sort.bam" "$bam_dir/$sm.sort.bam.bai" && \

    # Generate idxstats
    samtools idxstats "$bam_dir/$sm.sort.bam" > "$idxstats_dir/$sm.idxstats.txt"
done

