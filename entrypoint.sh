#! /bin/bash

die() { echo "$@" 1>&2 ; exit 1; }

log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

if [ ! -n "${LETSENCRYPT_HOSTNAMES}" ]; then
  die "Missing environment variable \$LETSENCRYPT_HOSTNAMES"
fi
IFS=':' read -r -a hostnames <<< "${LETSENCRYPT_HOSTNAMES}"

if [ ! -n "${LETSENCRYPT_EMAIL}" ]; then
  die "Missing environment variable \$LETSENCRYPT_EMAIL"
fi

hostargs=()
for i in "${hostnames[@]}"
do
	 hostargs+=("-d $i")
done

CERTBOT_CMD="/opt/certbot/venv/bin/certbot certonly --non-interactive --email ${LETSENCRYPT_EMAIL} ${hostargs[@]}"

function create {
  echo "Requesting certificate for hostname(s) \"${hostnames[@]}\"..."
  ${CERTBOT_CMD} || die "Failed to issue certificate."
}

function auto_renew {
  echo "Checking renewal for hostname(s) \"${hostnames[@]}\"..."
  ${CERTBOT_CMD} || die "Failed to renew certificate."
}

# Check if certificate already exists
if [ ! -e "/etc/letsencrypt/live/${hostnames[0]}" ]; then
  create
else
  auto_renew
fi

# Check autorenewal twice a day (as recommended by Lets encrypt)
while :
do
  sleep 12h
  auto_renew
done
