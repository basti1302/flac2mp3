#!/usr/bin/env bash

SOURCE='/mnt/fileserver/media/audio/musik/mp3'

function convertMp3ToFlac {
  ffmpeg -n -v error -i "$1" -map_metadata 0 "$2";
}
export -f convertMp3ToFlac

function convertMp3ToFlacIfNewer {
  TARGET_DIR='/mnt/fileserver/media/audio/musik/flac'

  SOURCE=$(pwd)/"$1"
  SOURCE_DIR=${SOURCE%/*}
  TARGET_FILE=${1:2}
  TARGET_DIR=$TARGET_DIR/${TARGET_FILE%/*}
  TARGET_FILE=${TARGET_FILE%.mp3}
  TARGET_FILE=${TARGET_FILE##*/}
  TARGET=$TARGET_DIR/$TARGET_FILE.flac

  if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    chmod 777 "$TARGET_DIR"
    echo "Created $TARGET_DIR"
  fi

  if [ -e "$TARGET" ]; then
    echo "$TARGET [exists]"
  else
    echo "Converting: $SOURCE >>> $TARGET [target did not exist]"
    convertMp3ToFlac "$SOURCE" "$TARGET"
  fi

  # Copy cover art etc.
  cp -nv "$SOURCE_DIR"/*.jpg "$SOURCE_DIR"/*.jpeg "$SOURCE_DIR"/*.png "$SOURCE_DIR"/*.gif "$SOURCE_DIR"/*.pdf "$SOURCE_DIR"/*.txt "$TARGET_DIR" 2> /dev/null
}
export -f convertMp3ToFlacIfNewer

pushd "$SOURCE" > /dev/null
# Convert MP3 to FLAC
find . -type f -iname \*.mp3 -exec bash -c 'convertMp3ToFlacIfNewer "$@"' bash {} \;
popd > /dev/null

