#!/bin/bash
set -e && cd "${0%/*}"

# creates a copy of the project in temporary directory
# and prepares the copy to be published

temp_pub_dir=$(mktemp -d -t pub-XXXXXXX)

echo "$temp_pub_dir"

rsync -Rrv ./ "$temp_pub_dir" \
  --exclude=".git" \
  --exclude="pubpub.sh" \
  --exclude="benchmark/" \
  --exclude="reference/" \
  --exclude="README.md" \
  --exclude=".github" \
  --exclude="labuda/"

# removing everything before "\n# ", the first header
old_readme=$(cat README.md | tr '\n' '\r')
new_readme=$(echo $old_readme | perl -p0e 's|^.*?\r# |# \1|' | tr '\r' '\n')
echo "$new_readme" > "$temp_pub_dir/README.md"

cd "$temp_pub_dir"
#dart pub publish --dry-run
dart pub publish
#open "$temp_pub_dir"