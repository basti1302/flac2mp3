#!/usr/bin/env bash

SOURCE='/mnt/fileserver/media/audio/musik/__CD_COLLECTION'

function convertFlacToMp3 {
  # Loses meta data
  # flac -d -c -s "$1"| lame --silent --preset insane - "$2"
  ffmpeg -v error -i "$1" -ab 320k -map_metadata 0 "$2";
}
export -f convertFlacToMp3

function convertFlacToMp3IfNewer {
  TARGET_DIR=/mnt/fileserver/media/audio/musik/__MP3_COLLECTION

  SOURCE=$(pwd)/"$1"
  SOURCE_DIR=${SOURCE%/*}
  TARGET_FILE=${1:2}
  TARGET_DIR=$TARGET_DIR/${TARGET_FILE%/*}
  TARGET_FILE=${TARGET_FILE%.flac}
  TARGET_FILE=${TARGET_FILE##*/}
  TARGET=$TARGET_DIR/$TARGET_FILE.mp3

  mkdir -p "$TARGET_DIR"
  if [ -e "$TARGET" ]; then
    if [ "$SOURCE" -nt "$TARGET" ]; then
      echo "Converting: $SOURCE >>> $TARGET [target existed but source was newer]"
      convertFlacToMp3 "$SOURCE" "$TARGET"
    else
      echo "$TARGET [exists and is up to date]"
    fi
  else
    echo "Converting: $SOURCE >>> $TARGET [target did not exist]"
    convertFlacToMp3 "$SOURCE" "$TARGET"
  fi

  # Copy cover art etc.
  cp -uv "$SOURCE_DIR"/*.jpg "$SOURCE_DIR"/*.jpeg "$SOURCE_DIR"/*.png "$SOURCE_DIR"/*.gif "$SOURCE_DIR"/*.pdf "$SOURCE_DIR"/*.txt "$TARGET_DIR" 2> /dev/null
}
export -f convertFlacToMp3IfNewer

pushd "$SOURCE" > /dev/null
# Convert FLAC to MP3
find . -type f -iname \*.flac -exec bash -c 'convertFlacToMp3IfNewer "$@"' bash {} \;
popd > /dev/null

