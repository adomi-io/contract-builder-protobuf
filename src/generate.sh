#!/bin/bash
set -e

# Base directory for Protobuf specifications
SRC_DIR="/local/src"

# Base directory for generated output
OUT_DIR="/local/out"

# Well-known types include path
WKT_DIR="${PROTOC_WKT_INCLUDE:-/usr/include}"

generate_client() {
    local spec_dir=$1
    local language=$2
    local client_name=$3
    
    echo "Generating $language client for $client_name..."
    
    local target_out="$OUT_DIR/$client_name/$language"
    mkdir -p "$target_out"

    # Find all .proto files in the spec directory
    PROTOS=()

    while IFS=  read -r -d $'\0'; do
        PROTOS+=("$REPLY")
    done < <(find "$spec_dir" -name "*.proto" -print0)

    if (( ${#PROTOS[@]} == 0 )); then
      echo "No .proto files found in $spec_dir"
      return
    fi

    # Construct the environment variable name for additional arguments
    # Convert language to uppercase and replace hyphens with underscores
    local lang_env=$(echo "$language" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    local env_var_name="GENERATOR_${lang_env}_ARGS"
    
    # Get the value of the environment variable using indirect reference
    local extra_args="${!env_var_name}"

    # Default output flag is --{language}_out
    # If the user wants to override this or add more (like grpc), they can use extra_args
    # Use eval to support variable expansion in extra_args
    eval "protoc \
      --proto_path=\"$SRC_DIR\" \
      --proto_path=\"$WKT_DIR\" \
      \"--${language}_out=$target_out\" \
      $extra_args \
      ${PROTOS[*]}"
}

# Process generators provided in the environment variable
GENERATORS=$(echo $GENERATORS | tr ',' ' ')

if [ -z "$GENERATORS" ]; then
    echo "No generators specified. Please set the GENERATORS environment variable."
    exit 0
fi

# We look for directories in SRC_DIR that contain .proto files
find "$SRC_DIR" -maxdepth 2 -name "*.proto" | xargs -L1 dirname | sort -u | while read spec_dir; do
    # Extract the service name from the directory structure
    # For /local/src/petshop -> petshop
    service_name=$(realpath --relative-to="$SRC_DIR" "$spec_dir" | cut -d/ -f1)
    
    for lang in $GENERATORS; do
        generate_client "$spec_dir" "$lang" "$service_name"
    done
done

echo "Generation complete. Outputs are in $OUT_DIR"
