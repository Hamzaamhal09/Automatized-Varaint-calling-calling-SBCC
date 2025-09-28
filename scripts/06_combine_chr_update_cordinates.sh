#!/bin/bash

### Script: Merge part-chromosome coordinates into full chromosomes in VCF
### Author: C.P. Cantalapiedra (modified with path variables)

#======================#
# Define Input/Output  #
#======================#

# ==== PATH VARIABLES ====
# Assume config file path is in $config_file
config_file="config/config_paths.yaml"

BED_FILE=$(yq -r '.BED_FILE' "$config_file")
FINAL_OUTPUT=$(yq -r '.FINAL_OUTPUT' "$config_file")
VCF_WITH_MERGED_COORDS=$(yq -r '.VCF_WITH_MERGED_COORDS' "$config_file")
VCF_WITH_MERGED_COORDS_GZ=$(yq -r '.VCF_WITH_MERGED_COORDS_GZ' "$config_file")
VCF_FINAL=$(yq -r '.VCF_FINAL' "$config_file")


#======================#
# Coordinate Remapping #
#======================#

awk 'FNR==NR{
    if ($5 != 0) { v[$4] = $5; }
    next
}
{
    if (substr($0, 1, 1) == "#") { print $0; next; }
    if ($1 == "chrUn") { print $0; next; }
    chrom = substr($1, 1, 5);
    part = substr($1, 7);
    pos = ($1 == "chrUn" || part == "0") ? $2 : ($2 + v[chrom]);
    printf chrom "\t" pos "\t";
    for (i = 3; i <= NF; i++) {
        printf $i;
        if (i < NF) printf "\t"; else printf "\n";
    }
}' "$BED_FILE" "$FINAL_OUTPUT" > "$VCF_WITH_MERGED_COORDS"




# Load chromosomes
# Load chromosomes from config
# Load chromosomes

# Loop over chromosomes
# Load chromosomes (without _partX)
mapfile -t CHROMOSOMES < <(yq -r '.CHROMOSOMES[]' "$config_file" | sed 's/_part[0-9]\+//g' | sort -u)

# Loop over chromosomes and replace all _partX in header
for CHR in "${CHROMOSOMES[@]}"; do
    echo "Replacing patterns for chromosome: $CHR"
    # Print what it will replace
    grep "ID=${CHR}_part" "$VCF_WITH_MERGED_COORDS"
    
    # Replace all _partX with the full chromosome name
    sed -i "s/ID=${CHR}_part[0-9]\+/ID=${CHR}/g" "$VCF_WITH_MERGED_COORDS"
done

#!/bin/bash

# Temporary file (not a new VCF variable)
tmp_file=$(mktemp)

num=$(yq -r '.CHROMOSOMES_length | length' "$config_file")

for ((i=0;i<num;i++)); do
    chr=$(yq -r ".CHROMOSOMES_length[$i].name" "$config_file")
    size=$(yq -r ".CHROMOSOMES_length[$i].size" "$config_file")

    echo "Updating length for $chr to $size in $VCF_WITH_MERGED_COORDS"

    sed -i -E "s/(ID=${chr},length=)[0-9]+/\1${size}/g" "$VCF_WITH_MERGED_COORDS"
done


awk '!seen[$0]++' "$VCF_WITH_MERGED_COORDS" > "${VCF_WITH_MERGED_COORDS}.tmp" && mv "${VCF_WITH_MERGED_COORDS}.tmp" "$VCF_WITH_MERGED_COORDS"


#======================#
# Compress & Index     #
#======================#
# Load chromosomes from config
# --- Fix header in-place ---




bgzip -c "$VCF_WITH_MERGED_COORDS" > "$VCF_WITH_MERGED_COORDS_GZ"
bcftools sort "$VCF_WITH_MERGED_COORDS_GZ" -o "$VCF_WITH_MERGED_COORDS_GZ.sorted"

#bcftools index -c "$VCF_WITH_MERGED_COORDS_GZ"

#======================#
# Add MISSING/MAF Tags #
#======================#

bcftools +fill-tags "$VCF_WITH_MERGED_COORDS_GZ" -- -t F_MISSING,MAF | \
    bcftools view -Oz -o "$VCF_FINAL"
