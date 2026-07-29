#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
#
# Build a dual-slot pbz: the mobile app installs into whichever slot is not
# running, so a single-slot bundle is rejected half the time.
set -e

board="${1:?usage: $0 <board>   e.g. $0 obelix@pvt}"

for slot in 0 1; do
  ./pbl configure --board "$board" -DCONFIG_FIRMWARE_SLOT="$slot"
  ./pbl build
  ./pbl bundle
done

slot0=$(ls -t build/normal_*_slot0.pbz | head -1)
slot1=$(ls -t build/normal_*_slot1.pbz | head -1)

merged="${slot1%_slot1.pbz}.pbz"

python3 tools/merge_pbz.py \
  --slot0-pbz "$slot0" \
  --slot1-pbz "$slot1" \
  --output "$merged"

printf 'Install %s now? [y/N] ' "$(basename "$merged")"
read -r answer
case "$answer" in
  y | Y)
    # Only the mobile app knows which slot is running; installing over the
    # running one bricks the watch. So hand the file over, don't flash it.
    printf '%s' "$merged" | pbcopy
    open -R "$merged"
    echo "Path copied to clipboard. Send it to the phone and sideload via the Pebble app."
    ;;
  *)
    echo "Skipped. Bundle: $merged"
    ;;
esac
