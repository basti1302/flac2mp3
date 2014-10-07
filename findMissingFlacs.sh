#!/usr/bin/env bash

SOURCE='/mnt/fileserver/media/audio/musik/mp3'

function findMissingFlacs {
  TARGET_DIR='/mnt/fileserver/media/audio/musik/flac'

  SOURCE=$(pwd)/"$1"
  SOURCE_DIR=${SOURCE%/*}
  TARGET_FILE=${1:2}
  TARGET_DIR=$TARGET_DIR/${TARGET_FILE%/*}
  TARGET_FILE=${TARGET_FILE%.mp3}
  TARGET_FILE=${TARGET_FILE##*/}
  TARGET=$TARGET_DIR/$TARGET_FILE.flac

  if [ ! -e "$TARGET" ]; then
    echo "$TARGET"
  fi
}
export -f findMissingFlacs

pushd "$SOURCE" > /dev/null
find . -type f -iname \*.mp3 -exec bash -c 'findMissingFlacs "$@"' bash {} \;
popd > /dev/null

