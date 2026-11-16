#!/bin/bash
#
# Install herdr with its official installer: the release binary for this CPU,
# SHA-256 checked, into ~/.local/bin. Not Homebrew: on Intel Macs the formula
# builds OpenSSL from source. Update later with: herdr update
curl -fsSL https://herdr.dev/install.sh | sh
