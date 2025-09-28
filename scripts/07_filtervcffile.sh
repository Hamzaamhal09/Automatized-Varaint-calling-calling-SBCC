#!/bin/bash

# Path to the input VCF file


config_file="config/config_paths.yaml"

VCF_FINAL=$(yq -r '.VCF_FINAL' "$config_file")
FILTERED_VCF=$(yq -r '.FILTERED_VCF' "$config_file")
FILTRED_OUTPUT_DIR=$(yq -r ".FILTRED_OUTPUT_DIR" "$config_file")

mkdir -p "$FILTRED_OUTPUT_DIR"


bcftools view -i 'INFO/DP>=5 & INFO/MAF>=0.05 & INFO/F_MISSING<=0.2' "$VCF_FINAL" | bgzip -c > "$FILTERED_VCF"
bcftools index "$FILTERED_VCF"

echo "Filtering complete. Output saved to $FILTERED_VCF"


# Filter the VCF file for variants with a depth (DP) of 5 or more,
# MAF greater than or equal to 0.05, and missingness less than or equal to 0.2
bcftools view -i 'INFO/DP>=5 & INFO/MAF>=0.05 & INFO/F_MISSING<=0.2' $INPUT_VCF | bgzip -c > $OUTPUT_VCF
bcftools index $OUTPUT_VCF

echo "Filtering complete. Output saved to $OUTPUT_VCF"
