#!/bin/bash

# OpenSSL Bash Warper - root ca script
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

source "$(dirname $0)/base.sh"

if [[ -f "$SSLDIR/certs/ca.crt" ]]; then
  echo -e "\n*** Root certificate already exists"
  echo -e "    Rename and start over\n"
  exit 1
fi

if [[ -f "$SSLDIR/private/ca.key" ]]; then
  echo -e "\n*** Key file already exists"
  echo -e "    Rename and start over\n"
  exit 1
fi


# Skeleton
mkdir -p "$SSLDIR/"{certs,newcerts,requests,private,crl}
chmod -R 750 "$SSLDIR/"{certs,newcerts,requests,private,crl}
echo '01' > "$SSLDIR/crlnumber"
echo '01' > "$SSLDIR/serial"
echo -n '' > "$SSLDIR/index.txt"
echo -n '' > "$SSLDIR/private/.rand"
chmod 640 "$SSLDIR/private/.rand"

# Prepare openssl.cnf
if [[ ! -e "$SSLDIR/openssl.cnf" ]]; then
  if [[ -s "$SSLDIR/openssl_example.cnf" ]]; then
    cp "$SSLDIR/openssl_example.cnf" "$SSLDIR/openssl.cnf"
  else
    echo -e "\n*** No openssl configuration file found. Exiting\n"
    exit 1
  fi
fi


# Self signed certificate

# Set defaults
params=($@)
[[ ${params[@]} == *'-newkey'* ]] || params+=('-newkey rsa:4096')
[[ ${params[@]} == *'-sha'* ]] || params+=('-sha512')
[[ ${params[@]} == *'-days'* ]] || params+=('-days 3650')

# Generate self signed certificate and key
echo -e "\n*** Creating self signed certificate\n"
openssl req ${params[@]} -new -x509 -nodes \
  -keyout "$SSLDIR/private/ca.key" \
  -out "$SSLDIR/certs/ca.crt"

# Error handling
if [[ ( $? -eq 0 ) && ( -s "$SSLDIR/private/ca.key" ) && ( -s "$SSLDIR/certs/ca.crt" ) ]]; then
  chmod 600 "$SSLDIR/private/ca.key"
else
  echo -e "\n*** Error or uncompleted operation. Exiting\n"
  exit 1
fi


# Encrypt private key. Key file will be deleted if unsuccessful
if [[ -s "$SSLDIR/private/ca.key" ]]; then
  echo -e "\n*** Encrypt private key"
  echo -e "    BE CAREFUL"
  echo -e "    Key file will be deleted if unsuccessful.\n"
  openssl rsa -aes256 -in "$SSLDIR/private/ca.key" -out "$SSLDIR/private/ca.key" || rm -f "$SSLDIR/{private,certs}/ca."*
fi


