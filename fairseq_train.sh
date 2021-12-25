#!/bin/bash
# Train fairseq model for predicting polish genetive case

set -eou pipefail

# Display help
Help() {
    echo "Train fairseq model for predicting polish genetive case"    
    echo "Syntax: fairseq_train.sh [-h|s|a|d|o|b|c|e|f|l|m|w|x|y|z]"
    echo "options:"
    echo "h)     Print help"
    echo "s)     Seed"
    echo "a)     Architecture"
    echo "d)     Save directory"
    echo "o)     Optimizer"
    echo "b)     Batch size"
    echo "c)     Activation function"
    echo "e)     Dropout"
    echo "f)     Max update"
    echo "l)     Learning rate"
    echo "m)     Label smoothing"
    echo "w)     Encoder embedding dimension"
    echo "x)     Decoder embedding dimension"
    echo "y)     Encoder hidden size"
    echo "z)     Decoder hidden size"
}

# Parse options
while getopts ":hs:a:d:o:b:c:e:f:l:m:w:x:y:z:" option; do
   case $option in
      h) # display Help
         Help
         exit 0;;
      s) seed=$OPTARG;;
      a) arch=$OPTARG;;
      d) save_dir=$OPTARG;;
      o) optimizer=$OPTARG;;
      b) batch_size=$OPTARG;;
      c) activation_function=$OPTARG;;
      e) dropout=$OPTARG;;
      f) max_update=$OPTARG;;
      l) learning_rate=$OPTARG;;
      m) label_smoothing=$OPTARG;;
      w) encoder_embed_dim=$OPTARG;;
      x) decoder_embed_dim=$OPTARG;;
      y) encoder_hidden_size=$OPTARG;;
      z) decoder_hidden_size=$OPTARG;;
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

if [ -z ${seed+x} ]; then
    readonly SEED=1
    echo "Setting default SEED = $SEED"
else
    readonly SEED=$seed
fi

if [ -z ${arch+x} ]; then
    readonly ARCH=lstm
    echo "Setting default ARCH = $ARCH"
else
    readonly ARCH=$arch
fi

if [ -z ${optimizer+x} ]; then
    readonly OPTIMIZER=adam
    echo "Setting default OPTIMIZER = $OPTIMIZER"
else
    readonly OPTIMIZER=$optimizer
fi

if [ -z ${batch_size+x} ]; then
    readonly BATCH_SIZE=128
    echo "Setting default BATCH_SIZE = $BATCH_SIZE"
else
    readonly BATCH_SIZE=$batch_size
fi

if [ -z ${learning_rate+x} ]; then
    readonly LEARNING_RATE=0.001
    echo "Setting default LEARNING_RATE = $LEARNING_RATE"
else
    readonly LEARNING_RATE=$learning_rate
fi

if [ -z ${label_smoothing+x} ]; then
    readonly LABEL_SMOOTHING=0.1
    echo "Setting default LABEL_SMOOTHING = $LABEL_SMOOTHING"
else
    readonly LABEL_SMOOTHING=$label_smoothing
fi

if [ -z ${encoder_embed_dim+x} ]; then
    readonly ENCODER_EMBED_DIM=128
    echo "Setting default ENCODER_EMBED_DIM = $ENCODER_EMBED_DIM"
else
    readonly ENCODER_EMBED_DIM=$encoder_embed_dim
fi

if [ -z ${decoder_embed_dim+x} ]; then
    readonly DECODER_EMBED_DIM=128
    echo "Setting default DECODER_EMBED_DIM = $DECODER_EMBED_DIM"
else
    readonly DECODER_EMBED_DIM=$decoder_embed_dim
fi

if [ -z ${encoder_hidden_size+x} ]; then
    readonly ENCODER_HIDDEN_SIZE=512
    echo "Setting default ENCODER_HIDDEN_SIZE = $ENCODER_HIDDEN_SIZE"
else
    readonly ENCODER_HIDDEN_SIZE=$encoder_hidden_size
fi

if [ -z ${decoder_hidden_size+x} ]; then
    readonly DECODER_HIDDEN_SIZE=512
    echo "Setting default DECODER_HIDDEN_SIZE = $DECODER_HIDDEN_SIZE"
else
    readonly DECODER_HIDDEN_SIZE=$decoder_hidden_size
fi

if [ -z ${activation_function+x} ]; then
    readonly ACTIVATION_FUNCTION="relu"
    echo "Setting default ACTIVATION_FUNCTION = $ACTIVATION_FUNCTION"
else
    readonly ACTIVATION_FUNCTION=$activation_function
fi

if [ -z ${dropout+x} ]; then
    readonly DROPOUT=0.2
    echo "Setting default DROPOUT = $DROPOUT"
else
    readonly DROPOUT=$dropout
fi

if [ -z ${max_update+x} ]; then
    readonly MAX_UPDATE=800
    echo "Setting default MAX_UPDATE = $MAX_UPDATE"
else
    readonly MAX_UPDATE=$max_update
fi


if [ $ARCH == "transformer" ]; then
    # Set transformer specific params
    ENCODER_LAYERS=4
    DECODER_LAYERS=4
    ENCODER_ATTENTION_HEADS=4
    DECODER_ATTENTION_HEADS=4
elif [ $ARCH == "lstm" ]; then
    DECODER_OUT_EMBED_DIM=128
fi


echo "${DECODER_EMBED_DIM}"
read -p "Press enter to continue"


if [ $ARCH == "lstm" ]; then
    (
    fairseq-train \
        data-bin \
        --source-lang eng.pres \
        --target-lang eng.past \
        --seed "${SEED}" \
        --arch "${ARCH}" \
        --dropout "${DROPOUT}" \
        --encoder-embed-dim "${ENCODER_EMBED_DIM}" \
        --decoder-embed-dim "${DECODER_EMBED_DIM}" \
        --encoder-hidden-size ${ENCODER_HIDDEN_SIZE} \
        --decoder-hidden-size ${DECODER_HIDDEN_SIZE} \
        --lr "${LEARNING_RATE}" \
        --optimizer "${OPTIMIZER}" \
        --clip-norm 1 \
        --keep-last-epochs -1 \
        --criterion label_smoothed_cross_entropy \
        --max-update "${MAX_UPDATE}" \
        --batch-size "${BATCH_SIZE}" \
        --label-smoothing "${LABEL_SMOOTHING}" \
        --save-dir "${SAVE_DIR}" \
        --encoder-bidirectional \
        --decoder-out-embed-dim ${DECODER_OUT_EMBED_DIM} \
     )
elif [ $ARCH == "transformer" ]; then
    readonly ENCODER_FFN_EMBED_DIM=512
    readonly DECODER_FFN_EMBED_DIM=512
    (
        fairseq-train \
            data-bin \
            --source-lang eng.pres \
            --target-lang eng.past \
            --seed "${SEED}" \
            --arch "${ARCH}" \
            --encoder-embed-dim "${ENCODER_EMBED_DIM}" \
            --encoder-layers "${ENCODER_LAYERS}" \
            --encoder-attention-heads "${ENCODER_ATTENTION_HEADS}" \
            --encoder-normalize-before \
            --encoder-ffn-embed-dim "${ENCODER_FFN_EMBED_DIM}" \
            --decoder-embed-dim "${DECODER_EMBED_DIM}" \
            --decoder-layers "${DECODER_LAYERS}" \
            --decoder-attention-heads "${DECODER_ATTENTION_HEADS}" \
            --decoder-normalize-before \
            --decoder-ffn-embed-dim "${ENCODER_FFN_EMBED_DIM}" \
            --lr "${LEARNING_RATE}" \
            --optimizer "${OPTIMIZER}" \
            --clip-norm 1 \
            --keep-last-epochs -1 \
            --criterion label_smoothed_cross_entropy \
            --max-update "${MAX_UPDATE}" \
            --batch-size "${BATCH_SIZE}" \
            --label-smoothing "${LABEL_SMOOTHING}" \
            --save-dir "${SAVE_DIR}" \
            --share-all-embeddings \
            --activation-fn "${ACTIVATION_FUNCTION}" \
            --adam-betas '(.9,.98)' \
            --disable-validation \
            --attention-dropout "${DROPOUT}" \
            --activation-dropout "${DROPOUT}" \
            --share-decoder-input-output-embed \
            --lr-scheduler inverse_sqrt \
            --warmup-init-lr 1e-7 \
            --warmup-updates 1000 \
            --save-interval 5
        )
fi

