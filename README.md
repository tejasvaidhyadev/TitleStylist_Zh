# TitleStylist_Zh
The following Repo is Hard fork of [TitleStylist](https://github.com/jind11/TitleStylist)  

The code uses the Chinese generation model [ProphetNet-Dialog-Zh](https://github.com/microsoft/ProphetNet/tree/master/ProphetNet_Dialog_Zh) for initializing the  base encoder-decoder architecture.  

Model uses ideas from TitleStylist (Style Layer Normalization and Style-Guided Encoder Attention) with base pretrained model as ProphetNet-Dialog-Zh with Masked Sequence to Sequence Pretraining inspire from [MASS](https://arxiv.org/pdf/1905.02450.pdf)

- [Pretrained ProphetNet-Dialog-Zh](https://msraprophetnet.blob.core.windows.net/prophetnet/release_checkpoints/prophetnet_dialog_zh.pt)

## Requirements
### Python packages
- Pytorch
- fairseq
- blingfire

In order to install them, you can run this command:

```
pip install -r requirements.txt
```

### Bash commands
In order to evaluate the generated headlines by ROUGE scores, you need to install the "files2rouge" package. To do so, run the following commands (provided by [this repository](https://github.com/pltrdy/files2rouge)):

```
pip install -U git+https://github.com/pltrdy/pyrouge
git clone https://github.com/pltrdy/files2rouge.git     
cd files2rouge
python setup_rouge.py
python setup.py install
```

## Usage
1. All data including the combination of CNN and NYT article and headline pairs, and the three style-specific corpora (humor, romance, and clickbait) mentioned in the paper have been placed in the folder "data".

2. Please download the pretrained model parameters of ProphetNet-Dialog-Zh from [this link](https://msraprophetnet.blob.core.windows.net/prophetnet/release_checkpoints/prophetnet_dialog_zh.pt), unzip it, and put the unzipped files into the folder "pretrained_model/prophet_zh/".

```
cd pretrained_model
mkdir prophet_zh
wget https://msraprophetnet.blob.core.windows.net/prophetnet/release_checkpoints/prophetnet_dialog_zh.pt
tar -xvzf prophetnet_dialog_zh.pt
cd ..
```


3. To train a headline generation model that can simultaneously generated a facutal and a stylistic headline, you can run the following command:
```
./train_mix_Zh_News_X.sh --style ZH_poem
```
Here the arugment YOUR_TARGET_STYLE specifies any style you would like to have, in this paper, we provide three options: humor, romance, clickbait. 

After running this command, the trained model parameters will be saved into the folder "tmp/exp".

4. If you want to evaluate the trained model and generate headlines (both factual and stylistic) using this model, please run the following command:

```
./evaluate_mix_Zh_News_X.sh --style style ZH_poem --model_dir MODEL_STORED_DIRCTORY
```
In this command, the argument MODEL_STORED_DIRCTORY specifies the directory which stores the trained model.





