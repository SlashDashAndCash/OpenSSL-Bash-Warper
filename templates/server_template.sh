#!/bin/bash

# OpenSSL Bash Warper - server certificate template
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

source "$(dirname $0)/base.sh"

# Subject Alternative Name (SAN)
# e.g. export SAN='DNS:hostname1.mydomain.com,DNS:hostname1,IP:8.8.8.8'
if [ -z "${SAN}" ]; then
  svrext='ssl_server'
else
  svrext='ssl_server_san'
  echo -e "\n*** $(tput setaf 7)Remember to unset SAN ***\n"
fi


# Certificate Singing Request (CSR)
if [ ! -f "$SSLDIR/requests/$(basename $0).csr" ]; then

  # Handle existing key file
  params=()
  if [ ! -f "$SSLDIR/private/$(basename $0).key" ]; then
    params+=('-keyout' "$SSLDIR/private/$(basename $0).key")
  else
    params+=('-key' "$SSLDIR/private/$(basename $0).key")
  fi

  echo -e "\n*** Creating Certificate Signing Request\n"
  openssl req -new -nodes \
    -out "$SSLDIR/requests/$(basename $0).csr" ${params[@]}

  # Error handling
  if [[ ( $? -eq 0 ) && ( -s "$SSLDIR/requests/$(basename $0).csr" ) ]]; then
    chmod 600 "$SSLDIR/private/$(basename $0).key"
  else
    echo -e "\n*** Error or uncompleted operation. Exiting\n"
    exit 1
  fi
fi


# Certificate (CRT)
if [ -f "$SSLDIR/certs/$(basename $0).crt" ]; then
  echo -e "\n*** Certficate file already exists! Rename and start over.\n"
  exit 1
else
  echo -e "\n*** Sign request with CA key\n"

  # Sign CSR. You can use your own parameters
  openssl ca $@ \
    -policy policy_server \
    -extensions ${svrext} \
    -out "$SSLDIR/certs/$(basename $0).crt" \
    -infiles "$SSLDIR/requests/$(basename $0).csr"

  # Error handling
  if [[ ( $? -eq 0 ) && ( -s "$SSLDIR/certs/$(basename $0).crt" ) ]]; then
    # Everythings fine
    echo -n ''
  else
    echo -e "\n*** Error or uncompleted operation. Exiting\n"
    exit 1
  fi
fi


# Create PKCS#12 file
source "$(dirname $0)/pkcs12.sh"


# Encrypt private key. Key file will be deleted if unsuccessful
if [[ -s "$SSLDIR/private/$(basename $0).key" ]]; then
  echo -e "\n*** Encrypt private key"
  echo -e "    BE CAREFUL"
  echo -e "    Key file will be deleted if unsuccessful.\n"
  openssl rsa -aes256 -in "$SSLDIR/private/$(basename $0).key" -out "$SSLDIR/private/$(basename $0).key" || rm -f "$SSLDIR/private/$(basename $0).key"
fi

