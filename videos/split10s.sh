#!/bin/bash
# Always split each .mp4 file into exactly 11 parts of 299 frames:
# Part 1 → frames 0–298
# Part 2 → frames 299–598
# ...
# Part 11 → frames 299*10 → 299*11 - 1

shopt -s nullglob
files=(*.mp4)
[ ${#files[@]} -eq 0 ] && { echo "No .mp4 files found."; exit 1; }

prefix="${files[0]%.mp4}"
counter=1

frames_per_part=299
parts_per_video=11

for file in "${files[@]}"; do
    echo "Processing: $file"

    for ((i=0; i<parts_per_video; i++)); do
        start=$((i * frames_per_part))
        end=$((start + frames_per_part - 1))

        output="${prefix}_${counter}.mp4"

        echo "  Creating $output (frames $start–$end)..."

        ffmpeg -v error \
            -i "$file" \
            -vf "select='between(n,$start,$end)',setpts=PTS-STARTPTS" \
            -af "aselect='between(n,$start,$end)',asetpts=PTS-STARTPTS" \
            -c:v libx264 -preset fast -crf 18 \
            -c:a aac -b:a 128k \
            "$output"

        ((counter++))
    done
done

echo "✅ Done! Created $((counter - 1)) parts total."
