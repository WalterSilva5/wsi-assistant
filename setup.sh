#!/bin/bash

version="v2.0.3"

if [ ! -d "./models/recognition" ]; then
    echo "Creating recognition folder"
    mkdir -p ./models/recognition
fi
if [ ! -d "./models/synthesis" ]; then
    echo "Creating synthesis folder"
    mkdir -p ./models/synthesis
fi

if [ ! -d "./models/synthesis/speaker_embeddings" ]; then
    echo "Creating speaker embeddings folder"
    mkdir -p ./models/synthesis/speaker_embeddings
else
    echo "Speaker embeddings folder exists"
fi

if [ ! -d "./models/recognition/vosk-model-small-pt-0.3" ]; then
    echo "Downloading Vosk model for Portuguese"
    wget https://alphacephei.com/vosk/models/vosk-model-small-pt-0.3.zip -O ./models/recognition/vosk-model-small-pt-0.3.zip
    echo "Unzipping Vosk model"
    unzip -o ./models/recognition/vosk-model-small-pt-0.3.zip -d ./models/recognition/
else
    echo "Vosk model for Portuguese already exists"
fi

if [ ! -f "./models/synthesis/XTTS-v2-config.json" ]; then
    echo "Downloading XTTS model files"
    wget https://huggingface.co/coqui/XTTS-v2/resolve/${version}/config.json -O ./models/synthesis/XTTS-v2-config.json
    wget https://coqui.gateway.scarf.sh/hf-coqui/XTTS-v2/${version}/vocab.json -O ./models/synthesis/XTTS-v2-vocab.json
    wget https://coqui.gateway.scarf.sh/hf-coqui/XTTS-v2/${version}/model.pth -O ./models/synthesis/XTTS-v2-model.pth
    wget https://coqui.gateway.scarf.sh/hf-coqui/XTTS-v2/${version}/speakers_xtts.pth -O ./models/synthesis/XTTS-v2-speakers.pth

    echo "XTTS model files downloaded successfully"

    mkdir -p ./models/synthesis/speaker_embeddings/
    sample_wav_url="https://github.com/daswer123/xtts-api-server/raw/main/example/"
    audio_names=("calm_female" "female" "male.wav")

    for((i=0; i<3; i++))
    do
        wget $sample_wav_url${audio_names[i]}.wav -O ./models/synthesis/speaker_embeddings/${audio_names[i]}.wav
    done
else
    echo "XTTS model files already exists"
fi

echo "Installing pyenv"
curl https://pyenv.run | bash

echo "Installing python 3.9.7"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
pyenv install 3.9.7 -s
pyenv global 3.9.7

echo "Installing dependencies"
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

echo "Setup complete"
echo "Run 'source .venv/bin/activate' to activate the virtual environment"
echo "Run 'python main.py' to start the application"