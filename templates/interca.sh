#!/bin/bash

# OpenSSL Bash Warper - intermediate ca script
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

source "$(dirname $0)/base.sh"

# Prepare intermediate CA
if [[ -z $1 ]]; then
  echo -e "\n*** You must provide a valid caname"
  echo -e "    Use: $(basename $0) caname\n"
  exit 1
else
  export CN="$1"

  if [[ -d "$SSLDIR/$1" ]]; then
    echo -e "\n*** CA already exists"
    echo -e "    $SSLDIR/$1 found\n"
    exit 1
  else
    # Skeleton
    mkdir -p $SSLDIR/$1/{certs,newcerts,requests,private,crl,templates}
    chmod -R 750 "$SSLDIR/$1"
    echo '01' > "$SSLDIR/$1/crlnumber"
    echo '01' > "$SSLDIR/$1/serial"
    echo -n '' > "$SSLDIR/$1/index.txt"
    echo -n '' > "$SSLDIR/$1/private/.rand"
    chmod 640 "$SSLDIR/$1/private/.rand"

    # Create config and hardlinks
    cp "$SSLDIR/openssl.cnf" "$SSLDIR/$1"
    ln "$SSLDIR/LICENSE" "$SSLDIR/$1/LICENSE"
    ln "$SSLDIR/README.md" "$SSLDIR/$1/README.md"
    ln "$SSLDIR/templates/base.sh" "$SSLDIR/$1/templates/base.sh"
    ln "$SSLDIR/templates/pkcs12.sh" "$SSLDIR/$1/templates/pkcs12.sh"
    ln "$SSLDIR/templates/user_template.sh" "$SSLDIR/$1/templates/user_template.sh"
    ln "$SSLDIR/templates/server_template.sh" "$SSLDIR/$1/templates/server_template.sh"
    ln "$SSLDIR/templates/interca.sh" "$SSLDIR/$1/templates/interca.sh"
    ln "$SSLDIR/templates/revoke_template.sh" "$SSLDIR/$1/templates/revoke_template.sh"
    ln "$SSLDIR/templates/archive.sh" "$SSLDIR/$1/templates/archive.sh"
  fi
fi


# Certificate Singing Request (CSR)
echo -e "\n*** Creating Certificate Signing Request\n"
openssl req -new -newkey rsa:4096 -sha512 -nodes \
  -keyout "$SSLDIR/$1/private/ca.key" \
  -out "$SSLDIR/$1/requests/ca.csr"

# Error handling
if [[ ( $? -eq 0 ) && ( -s "$SSLDIR/$1/private/ca.key" ) && ( -s "$SSLDIR/$1/requests/ca.csr" ) ]]; then
  chmod 600 "$SSLDIR/$1/private/ca.key"
else
  echo -e "\n*** Error or uncompleted operation. Exiting\n"
  exit 1
fi


# Certificate (CRT)
if [ -f "$SSLDIR/$1/certs/ca.crt" ]; then
  echo -e "\n*** Certficate file already exists! Rename and start over.\n"
  exit 1
else
  echo -e "\n*** Sign request with CA key\n"

  # Set defaults
  params=($@)
  unset params[0]
  [[ ${params[@]} == *'-md'* ]] || params+=('-md' 'sha512')
  [[ ${params[@]} == *'-days'* ]] || params+=('-days 3650')

  openssl ca ${params[@]} \
    -extensions v3_ca \
    -out "$SSLDIR/$1/certs/ca.crt" \
    -infiles "$SSLDIR/$1/requests/ca.csr"

  # Error handling
  if [[ ( $? -eq 0 ) && ( -s "$SSLDIR/$1/certs/ca.crt" ) ]]; then
    # Everything's fine
    echo -n ''
  else
    echo -e "\n*** Error or uncompleted operation. Exiting\n"
    exit 1
  fi
fi


# Encrypt private key. Key file will be deleted if unsuccessful
if [[ -s "$SSLDIR/$1/private/ca.key" ]]; then
  echo -e "\n*** Encrypt private key"
  echo -e "    BE CAREFUL"
  echo -e "    Key file will be deleted if unsuccessful.\n"
  openssl rsa -aes256 -in "$SSLDIR/$1/private/ca.key" -out "$SSLDIR/$1/private/ca.key" || rm -f "$SSLDIR/$1/{private,requests,certs}/ca."*
fi


# Link issuer certificate to certs directory
echo -e "\n*** Link issuer certificate to certs directory"
[[ -f "$SSLDIR/certs/ca-chain_"*.crt ]] && cp -lv "$SSLDIR/certs/ca-chain_"*.crt "$SSLDIR/$1/certs/"
cp -lv "$SSLDIR/certs/ca.crt" "$SSLDIR/$1/certs/ca-chain_${CANAME}.crt"

