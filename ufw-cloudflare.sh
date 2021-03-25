#!/usr/bin/env bash
# script from https://gadelkareem.com/2019/06/11/allow-cloudflare-ips-on-port-80-and-443-using-ufw/

set -euo pipefail

# lock it
PIDFILE="/tmp/$(basename "${BASH_SOURCE[0]%.*}.pid")"
exec 200>${PIDFILE}
flock -n 200 || ( echo "${BASH_SOURCE[0]} script is already running. Aborting . ." && exit 1 )
PID=$$
echo ${PID} 1>&200


cd "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))"
CUR_DIR="$(pwd)"


wget https://www.cloudflare.com/ips-v4 -O ips-v4
wget https://www.cloudflare.com/ips-v6 -O ips-v6


for cfip in `cat ips-v4`; do /usr/sbin/ufw allow from $cfip to any port 443 proto tcp comment "cloudflare ssl"; done
for cfip in `cat ips-v6`; do /usr/sbin/ufw allow from $cfip to any port 443 proto tcp comment "cloudflare ssl"; done

/usr/sbin/ufw reload > /dev/null
