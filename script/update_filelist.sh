#!/bin/sh

base="/mnt/array1/fiord-storage"

exts=(".jpg" ".JPG" ".png" ".PNG" ".jpeg" ".JPEG" ".mp4" ".avi" ".MP4")
files=()

for ext in ${exts[@]}; do
        orig_ifs=$IFS
        IFS=$'\n'
        list=(`find $base -name "*" | grep -v "trashbox" | grep -v ".webaxs/thumbnail" | grep $ext`)
        IFS=$orig_ifs

        for ((i = 0; i < ${#list[@]}; i++)); do
                f=${list[i]}
                mtime=`date -r "$f" "+%s"`
                files+=("$mtime ${f#$base}")

                # create 500x500 thumbnail image if not exist
                dir=`dirname "$f"`
                name=`basename "$f"`
                thumbnail_path="$dir/.webaxs/thumbnail/$name.3L.jpg"
                if [ ! -f "$thumbnail_path" ]; then
                        /usr/local/webaxs/bin/mkthumbnail 500 500 "$f" "$thumbnail_path"
                fi
        done
done

# sort files and write to index file
orig_ifs=$IFS
IFS=$'\n'
echo "${files[*]}" | sort -n > ${base}/.webaxs/index.txt
IFS=$orig_ifs
