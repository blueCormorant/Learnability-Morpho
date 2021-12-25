#!/bin/bash
# Preprocess train, test, and dev files for morpho-english fairseq model

set -eou pipefail

# Display help
Help() {
    echo "Preprocess train, test, and dev files for morpho-english fairseq model"    
    echo "Syntax: fairseq_preprocess.sh [-h|j]"
    echo "j) Create joined dictionary"
}

# Parse options
while getopts ":hj" option; do
   case $option in
       h) # display Help
          Help
          exit 0;;
       j) joined_dictionary=true;;
      \?) echo "Error: Invalid option"
          exit 1;;
   esac
done

if [ joined_dictionary ]; then
    (
    fairseq-preprocess \
        --source-lang eng.pres \
        --target-lang eng.past \
        --trainpref train \
        --validpref dev \
        --testpref test \
        --tokenizer space \
        --thresholdsrc 2 \
        --thresholdtgt 2 \
        --joined-dictionary
    )
else
    (
    fairseq-preprocess \
        --source-lang eng.pres \
        --target-lang eng.past \
        --trainpref train \
        --validpref dev \
        --testpref test \
        --tokenizer space \
        --thresholdsrc 2 \
        --thresholdtgt 2 \
    )
fi

