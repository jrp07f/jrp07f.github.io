#!/bin/bash

# Removes webp images from the project
function remove_web_p() {
    find 'assets' -type f -and -iname "*.webp" \
    -exec bash -c '
    webp_path=$(sed 's/\.[^.]*$/.webp/' <<< "$0");
    rm "$webp_path"
    ' {} \;
    echo "Removed webP files from the assets folder"
}

# Converts files with specific extensions into webP
function convert_files() {
    find 'assets' -type f -and \( -iname "*.$1" \) -not -path "*/launcher/*" \
    -exec bash -c '
    webp_path=$(sed 's/\.[^.]*$/.webp/' <<< "$0");
    if [ ! -f "$webp_path" ]; then
    cwebp -quiet -q 90 "$0" -o "$webp_path";
    rm "$0"
    fi;' {} \;
    echo "Converted images with $1 extension to webP"
}

function convert_gifs() {
  find 'assets' -type f -and \( -iname "*.gif" \) -not -path "*/launcher/*" \
  -exec bash -c '
  webp_path=$(sed 's/\.[^.]*$/.webp/' <<< "$0");
  if [ ! -f "$webp_path" ]; then
    gif2webp -quiet -min_size -m 6 -q 50 -mixed -mt "$0" -o "$webp_path";
    rm "$0"
  fi;' {} \;
  echo "Converted gifs to webP"
}

function setup_webp_converter() {
    echo "Updating or installing brew..."
    install_brew
    echo "install webP convert..."
    brew install webp
}

function install_brew() {
    which -s brew
    if [[ $? != 0 ]] ; then
        # Install Homebrew
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        brew update
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--setup)
        setup_webp_converter
        shift
        ;;
        -c|--clean)
        remove_web_p
        shift
        ;;
        -*|--*)
        echo "Unknown option"
        exit 1
        ;;
    esac
done

convert_files "jpeg"
convert_files "jpg"
convert_files "png"
#convert_gifs