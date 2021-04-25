#!/usr/bin/env bash
# process CNN_NYT headlines corpora
DATA_DIR=data_zh/ZH_News
OUT_DIR=data_zh/ZH_News/processed

for SPLIT in train valid test; do
    python encode.py \
        --inputs $DATA_DIR/content/content.${SPLIT} \
        --outputs $DATA_DIR/${SPLIT}.src \
        --workers 30; \
    python encode.py \
        --inputs $DATA_DIR/title/title.${SPLIT} \
        --outputs $DATA_DIR/${SPLIT}.tgt \
        --workers 30; \
done

fairseq-preprocess \
    --user-dir prophetnet --task masked_s2s \
    --source-lang src --target-lang tgt \
    --trainpref $DATA_DIR/train \
    --validpref $DATA_DIR/valid \
    --testpref $DATA_DIR/test \
    --destdir $OUT_DIR \
    --srcdict pretrained_model/prophetnet_chinese_dict/vocab_for_fairseq.txt \
    --tgtdict pretrained_model/prophetnet_chinese_dict/vocab_for_fairseq.txt \
    --workers 20

# process the three corpora of styles humor, romance, and clickbait
for STYLE in ZH_poem; do
    DATA_DIR=data_zh/$STYLE
    train=$DATA_DIR/$STYLE.train.bpe
    valid=$DATA_DIR/$STYLE.valid.bpe
    test=$DATA_DIR/$STYLE.test.bpe
    tmp=$DATA_DIR/$STYLE.tmp.bpe

    python encode.py \
        --inputs $DATA_DIR/$STYLE.raw \
        --outputs $DATA_DIR/$STYLE.bpe \
        --workers 30 \
        --tokenizer bpe \

    awk -v train="$tmp" -v test="$test" '{if(rand()<0.98) {print > train} else {print > test}}' $DATA_DIR/$STYLE.bpe
    awk -v train="$train" -v valid="$valid" '{if(rand()<0.98) {print > train} else {print > valid}}' $tmp
    rm $tmp

    DEST_DIR=data_zh/$STYLE/processed
    fairseq-preprocess \
    --user-dir prophetnet \
    --task translation_mix \
    --only-source \
    --trainpref $train \
    --validpref $valid \
    --testpref $test \
    --destdir $DEST_DIR \
    --workers 20 \
    --srcdict pretrained_model/prophetnet_chinese_dict/vocab_for_fairseq.txt;

    for split in train valid; do
        cp $DEST_DIR/$split.idx $DEST_DIR/$split.$STYLE-None.$STYLE.idx
        cp $DEST_DIR/$split.bin $DEST_DIR/$split.$STYLE-None.$STYLE.bin
    done

    cp $DEST_DIR/test.bin $DEST_DIR/test.noise-$STYLE.$STYLE.bin
    cp $DEST_DIR/test.idx $DEST_DIR/test.noise-$STYLE.$STYLE.idx
    cp $DEST_DIR/dict.txt $DEST_DIR/dict.noise.txt
    cp $DEST_DIR/dict.txt $DEST_DIR/dict.$STYLE.txt;
done