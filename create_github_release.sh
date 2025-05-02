#!/bin/bash

# Script to create a GitHub Release with opus files (or mp3 files)
# This script requires the GitHub CLI (gh) to be installed and authenticated

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit: https://cli.github.com/ for installation instructions"
    exit 1
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "Error: You are not authenticated with GitHub CLI."
    echo "Please run 'gh auth login' to authenticate."
    exit 1
fi

# Check if opus directory exists (preferred) or mp3 directory as fallback
if [ -d "opus" ]; then
    AUDIO_FORMAT="opus"
    AUDIO_DIR="opus"
elif [ -d "mp3" ]; then
    AUDIO_FORMAT="mp3"
    AUDIO_DIR="mp3"
else
    echo "Error: Neither opus nor mp3 directory found."
    echo "Please run convert_flac_to_opus.sh (recommended) or convert_flac_to_mp3.sh first."
    exit 1
fi

echo "Using $AUDIO_FORMAT format for release."

# Ask for release tag
read -p "Enter release tag (e.g., v1.0.0): " RELEASE_TAG

# Ask for release title
read -p "Enter release title: " RELEASE_TITLE

# Ask for release notes
echo "Enter release notes (press Ctrl+D when done):"
RELEASE_NOTES=$(cat)

# Create a temporary zip file of the audio directory
echo "Creating zip file of $AUDIO_DIR directory..."
zip -r ${AUDIO_FORMAT}_files.zip $AUDIO_DIR/

# Create the release
echo "Creating GitHub Release..."
gh release create "$RELEASE_TAG" ${AUDIO_FORMAT}_files.zip --title "$RELEASE_TITLE" --notes "$RELEASE_NOTES"

# Clean up
rm ${AUDIO_FORMAT}_files.zip

# Update the AudioLoader configuration in index.html
echo "Updating AudioLoader configuration in index.html..."
sed -i "s/releaseTag: '[^']*'/releaseTag: '$RELEASE_TAG'/g" index.html

echo "Done! GitHub Release created with tag: $RELEASE_TAG"
echo "The AudioLoader configuration in index.html has been updated."
echo ""
echo "To use jsDelivr CDN, your audio files can now be accessed at:"
echo "https://cdn.jsdelivr.net/gh/$(gh repo view --json nameWithOwner -q .nameWithOwner)@$RELEASE_TAG/$AUDIO_DIR/samples/[directory]/[filename].$AUDIO_FORMAT"