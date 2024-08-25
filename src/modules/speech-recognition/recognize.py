import os
import queue
import sounddevice as sd
import vosk
import sys
from typing import Any
from time import sleep

model_dir = "vosk-model-small-pt-0.3"
current_path = os.path.dirname(os.path.realpath(__file__))
print(f"Current path: {current_path}")

root_path = current_path.split("src")[0]
model_path = os.path.join(root_path, f"models/recognition/{model_dir}")
print(f"Model path: {model_path}")

sleep(4)
if not os.path.exists(model_path):
    print(f"Modelo não encontrado no caminho: {model_path}")
    exit(1)

model = vosk.Model(model_path)

samplerate = 16000
device = None #device to use for recording audio
q: Any = queue.Queue()


def callback(indata, frames, time, status):
    if status:
        print(status, file=sys.stderr)
    q.put(bytes(indata))


def recognize():
    with sd.RawInputStream(
        samplerate=samplerate,
        blocksize=8000,
        device=device,
        dtype='int16',
        channels=1, callback=callback):
        print("Diga algo...")
        rec = vosk.KaldiRecognizer(model, samplerate)
        while True:
            data = q.get()
            if rec.AcceptWaveform(data):
                print(rec.Result())
            else:
                print(rec.PartialResult())


if __name__ == "__main__":
    recognize()
