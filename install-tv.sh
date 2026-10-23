#!/usr/bin/env bash
# Installs Riyadh Screen on an LG webOS TV in Developer Mode.
# Usage: bash install-tv.sh <TV_IP> <PASSPHRASE>
set -e
IP="$1"; PASS="$2"
[ -z "$IP" ] || [ -z "$PASS" ] && { echo "Usage: bash install-tv.sh <TV_IP> <PASSPHRASE>"; exit 1; }
BRANCH="${BRANCH:-webos-app}"
REPO=https://raw.githubusercontent.com/lawibreak/riyadh-screen/$BRANCH
IPK=com.lawibreak.riyadhscreen_1.1.0_all.ipk
command -v npx >/dev/null || { echo "Install Node.js first: https://nodejs.org"; exit 1; }
ARES="npx -y -p @webos-tools/cli"
echo "Getting key from TV (Key Server must be on)..."
mkdir -p ~/.ssh
curl -fsS -m 15 "http://$IP:9991/webos_rsa" -o ~/.ssh/riyadh_tv_webos
chmod 600 ~/.ssh/riyadh_tv_webos
$ARES ares-setup-device -r riyadhtv >/dev/null 2>&1 || true
$ARES ares-setup-device -a riyadhtv -i "host=$IP" -i "port=9922" -i "username=prisoner" \
  -i "privatekey=riyadh_tv_webos" -i "passphrase=$PASS"
curl -fsSL "$REPO/$IPK" -o "/tmp/$IPK"
$ARES ares-install --device riyadhtv "/tmp/$IPK"
$ARES ares-launch --device riyadhtv com.lawibreak.riyadhscreen
echo "Done — Riyadh Screen is installed and running on the TV."
