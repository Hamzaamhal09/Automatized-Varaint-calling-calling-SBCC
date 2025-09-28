#!/bin/bash

# Load config from YAML using yq
CONFIG_FILE="config/config_paths.yaml"

# Extract input/output directories from YAML
fastq_input=$(yq -r '.fastq_input' "$CONFIG_FILE")
quality_check_output=$(yq -r '.quality_check_output' "$CONFIG_FILE")

# Create output directory if it doesn't exist
mkdir -p "$quality_check_output"

# Check if there are any fastq.gz files
shopt -s nullglob
fastq_files=("$fastq_input"/*.fastq.gz)

if [ ${#fastq_files[@]} -eq 0 ]; then
    echo "No .fastq.gz files found in $fastq_input"
    exit 1
fi

# Run FastQC on all .fastq.gz files
for file in "${fastq_files[@]}"; do
    echo "Running FastQC on $file..."
    fastqc -o "$quality_check_output" "$file"
done

# Run MultiQC to summarize FastQC results
echo "Running MultiQC..."
multiqc "$quality_check_output" -o "$quality_check_output"

echo "All done. FastQC and MultiQC reports are in $quality_check_output"

