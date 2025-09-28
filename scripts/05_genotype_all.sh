## CPCantalapiedra 2017
## Modified by Ruben Sancho, 2024, EEAD-CSIC

# ==== PATH VARIABLES ====
# Assume config file path is in $config_file
config_file="config/config_paths.yaml"

GATK=$(yq -r '.GATK' "$config_file")
REFERENCE_GENOME=$(yq -r '.reference_genome' "$config_file")

OUTPUT_DIR_SINGLE_GVCF=$(yq -r '.output_dir_singl_gvcf' "$config_file")
COMBINED_GVCF_DIR=$(yq -r '.COMBINED_GVCF_DIR' "$config_file")
TEMP_DIR=$(yq -r '.TEMP_DIR' "$config_file")

INTERVAL_LIST=$(yq -r '.INTERVAL_LIST' "$config_file")
SAMPLE_MAP=$(yq -r '.SAMPLE_MAP' "$config_file")

FINAL_OUTPUT=$(yq -r '.FINAL_OUTPUT' "$config_file")
PER_CHR_OUTPUT_PREFIX=$(yq -r '.PER_CHR_OUTPUT_PREFIX' "$config_file")

# For the chromosome list, we can read them into a bash array
mapfile -t CHROMOSOMES < <(yq -r '.CHROMOSOMES[]' "$config_file")


# === Create necessary directories if they do not exist ==="
mkdir -p "$TEMP_DIR"


# ==== STEP 1: Combine GVCFs using GenomicsDBImport ====
"$GATK" --java-options "-Xmx250g -DGATK_STACKTRACE_ON_USER_EXCEPTION=true" GenomicsDBImport \
    --genomicsdb-workspace-path "$COMBINED_GVCF_DIR" \
    --intervals "$INTERVAL_LIST" \
    --batch-size 25 \
    --consolidate true \
    --interval-merging-rule ALL \
    --reference "$REFERENCE_GENOME" \
    --tmp-dir "$TEMP_DIR" \
    --reader-threads 5 \
    --sample-name-map "$SAMPLE_MAP"


for CHR in "${CHROMOSOMES[@]}"; do
    OUTPUT_FILE="${PER_CHR_OUTPUT_PREFIX}_${CHR}.vcf"
    if [ ! -f "$OUTPUT_FILE" ]; then
        "$GATK" --java-options "-Xmx200g" GenotypeGVCFs \
            -R "$REFERENCE_GENOME" \
            -O "$OUTPUT_FILE" \
            -V "gendb://${COMBINED_GVCF_DIR}" \
            -L "$CHR"
    else
        echo "File $OUTPUT_FILE already exists, skipping $CHR."
    fi
done

"$GATK" --java-options "-Xmx200g" GatherVcfs \
    -R "$REFERENCE_GENOME" \
    -O "$FINAL_OUTPUT" \
    $(for CHR in "${CHROMOSOMES[@]}"; do echo -n "-I ${PER_CHR_OUTPUT_PREFIX}_${CHR}.vcf "; done)
