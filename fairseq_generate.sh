#!/bin/bash
# Generate predictions for morpho-english fairseq model

set -eou pipefail

# Display help
Help() {
    echo "Generate predicitons for morpho-english fairseq model"
    echo "Syntax: fairseq_generate.sh [-h|d|b|o]"
    echo "d) Save directory"
    echo "b) Beam"
    echo "o) Output file"
    echo "g) Gen subset"
}

# Parse options
while getopts ":hb:d:o:g:" option; do
   case $option in
      h) # display Help
         Help
         exit 0;;
      d) save_dir=$OPTARG;;
      b) beam=$OPTARG;;
      o) out_file=$OPTARG;;
      g) gen_subset=$OPTARG;;
      \?)echo "Error: Invalid option"
         exit 1;;
   esac
done

if [ -z ${save_dir+x} ]; then
    echo "You must specify a save directory (e.g. part4, part5, etc...)"
    exit 1
else
    readonly SAVE_DIR=$save_dir
fi

if [ -z ${beam+x} ]; then
    readonly BEAM=8
    echo "Setting default BEAM = $BEAM"
else
    readonly BEAM=$beam
fi

if [ -z ${out_file+x} ]; then
    readonly OUT_FILE="predictions.txt"
    echo "Setting default OUT_FILE = $OUT_FILE"
else
    readonly OUT_FILE=$out_file
fi

if [ -z ${gen_subset+x} ]; then
    readonly GEN_SUBSET="test"
    echo "Setting default GEN_SUBSET = $GEN_SUBSET"
else
    readonly GEN_SUBSET=$gen_subset
fi

read -p "Press enter to continue"

fairseq-generate \
    data-bin \
    --source-lang eng.pres \
    --target-lang eng.past \
    --path "${SAVE_DIR}"/checkpoint_last.pt \
    --gen-subset "${GEN_SUBSET}" \
    --beam "${BEAM}" \
    > "${OUT_FILE}"

