# Docker Demucs for Langkit

This is a fork of [xserrat/docker-facebook-demucs](https://github.com/xserrat/docker-facebook-demucs),
updated to use [demucs-inference](https://github.com/Ryan5453/demucs) with modern dependencies.

## Features

- **CUDA 12.6 support** - Works with modern NVIDIA GPUs (RTX 30/40/50 series)
- **Python 3.12** with PyTorch 2.x
- **demucs-inference** - Modern fork with `htdemucs`, `htdemucs_ft`, `htdemucs_6s` models
- **Pre-downloaded models** - htdemucs model weights included in the image
- **CPU fallback** - Works without GPU, just slower

## Usage with Langkit

This image is designed for use with [Langkit](https://github.com/tassa-yoniso-manasi-karoto/langkit)'s
Docker-based voice separation feature. Langkit manages the container lifecycle automatically.

## Manual Usage

Build the image:
```bash
docker-compose build
```

Run a separation:
```bash
# Start the container
docker-compose up -d

# Run demucs
docker exec langkit-demucs demucs separate -m htdemucs --isolate-stem vocals -f flac /data/input/mysong.mp3

# Output will be in ./output/htdemucs/mysong/vocals.flac
```

### CLI Options

```
demucs separate [OPTIONS] TRACKS...

Options:
  -m, --model          Model to use (htdemucs, htdemucs_ft, htdemucs_6s, hdemucs_mmi)
  --isolate-stem       Isolate specific stem (vocals, drums, bass, other, guitar, piano)
  -f, --format         Output format (wav, flac, mp3, etc.)
  -o, --output         Output path template
  --shifts             Random shifts for quality (1-20, default 1)
  --split-overlap      Overlap between chunks (0.0-1.0, default 0.25)
```

## Models

| Model | Description |
|-------|-------------|
| htdemucs | Default hybrid transformer model (4 stems) |
| htdemucs_ft | Fine-tuned version, better for vocals/bass/other |
| htdemucs_6s | 6-stem model (adds guitar, piano) |
| hdemucs_mmi | Better for long files (>7 min) |

## License

This repository is released under the MIT license as found in the [LICENSE](LICENSE) file.
