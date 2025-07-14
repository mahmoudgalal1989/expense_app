#!/bin/bash

# Create fonts directory if it doesn't exist
mkdir -p assets/fonts

# Download Sora font files from Google Fonts
curl -L -o assets/fonts/Sora-Regular.ttf "https://github.com/sora-xor/sora-fonts/raw/main/fonts/ttf/Sora-Regular.ttf"
curl -L -o assets/fonts/Sora-SemiBold.ttf "https://github.com/sora-xor/sora-fonts/raw/main/fonts/ttf/Sora-SemiBold.ttf"
curl -L -o assets/fonts/Sora-Bold.ttf "https://github.com/sora-xor/sora-fonts/raw/main/fonts/ttf/Sora-Bold.ttf"

echo "Fonts downloaded successfully to assets/fonts/"
