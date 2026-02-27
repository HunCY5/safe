#!/bin/sh
set -e

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

mise use tuist@4.45.1 -g
mise x tuist@4.45.1 -- tuist install
mise x tuist@4.45.1 -- tuist generate

pod install
