#
# Read arguments
#
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  --style)
    STYLE="$2"; shift 2;;
  *)
  POSITIONAL+=("$1")
  shift
  ;;
esac
done
set -- "${POSITIONAL[@]}"

SUMM_DIR=data_zh/ZH_News/processed
DAE_DIR=data_zh/$STYLE/processed
PRETRAINED_MODEL_PATH=pretrained_model/prophet_zh/prophetnet_zh.pt

SAVE_DIR=tmp/exp

python train.py \
    $SUMM_DIR:$DAE_DIR \
    --user-dir prophetnet --task translation_mix --arch ngram_transformer_prophet_large \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --lr 0.0005 --min-lr 1e-09 \
    --lr-scheduler inverse_sqrt --warmup-init-lr 1e-07 --warmup-updates 4000 \
    --dropout 0.1 --attention-dropout 0.1 --weight-decay 0.0 \
    --criterion ngram_language_loss --label-smoothing 0.1 \
    --update-freq 4 --max-tokens 1400  \
    --ddp-backend=no_c10d --max-epoch 6 \
    --max-source-positions 512 --max-target-positions 512 \
    --skip-invalid-size-inputs-valid-test \
    --dropout 0.2 \
    --load-from-pretrained-model $PRETRAINED_MODEL_PATH \
    --model_lang_pairs src-tgt $STYLE-$STYLE --lang-pairs src-tgt --dae-styles $STYLE \
    --lambda-parallel-config 0.5 --lambda-denoising-config 0.5 \
    --max-word-shuffle-distance 5 \
    --word-dropout-prob 0.2 \
    --word-blanking-prob 0.2 \
    --divide-decoder-self-attn-norm True \
    --divide-decoder-final-norm True \
    --divide-decoder-encoder-attn-query True \
    --save-dir $SAVE_DIR