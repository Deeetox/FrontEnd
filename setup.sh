#!/bin/bash
set -e

# Install basic dependencies for Flutter
apt-get update
apt-get install -y --no-install-recommends curl git unzip xz-utils

# Download Flutter SDK if not present
if [ ! -d "$HOME/flutter" ]; then
  curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz -o /tmp/flutter.tar.xz
  mkdir -p "$HOME"
  tar xf /tmp/flutter.tar.xz -C "$HOME"
fi

export PATH="$HOME/flutter/bin:$PATH"

# Run Flutter tool to download packages
if [ -f "deetox/pubspec.yaml" ]; then
  (cd deetox && flutter pub get)
fi
