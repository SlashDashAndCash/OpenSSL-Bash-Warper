#!/bin/bash

# OpenSSL Bash Warper - revocation template
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

source "$(dirname $0)/base.sh"

# Revoke certificate and generate CRL
if [ ! -f "$SSLDIR/certs/$(basename $0).crt" ]; then
  echo -e "\n*** No certificate file found. Exiting\n"
  exit 1
else
  echo -e "\n*** Revoke certifikate\n"
  openssl ca -revoke "$SSLDIR/certs/$(basename $0).crt"

  echo -e "\n*** Signing new CRL file\n"
  openssl ca -gencrl -out "$SSLDIR/crl/${CANAME}.crl"

  echo -e "\n*** All done.\n"
fi

# Rename certificate files
"$(dirname $0)/archive.sh" "$(basename $0)"

