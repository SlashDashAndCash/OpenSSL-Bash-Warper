#!/bin/bash

# OpenSSL Bash Warper - archive script
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

source "$(dirname $0)/base.sh"

filebase="${1}"
olddate=$(date +%Y-%m-%d)

[ -f "$SSLDIR/requests/${filebase}.csr" ] && mv "$SSLDIR/requests/${filebase}.csr" "$SSLDIR/requests/${filebase}_${olddate}.csr"
[ -f "$SSLDIR/certs/${filebase}.crt" ]    && mv "$SSLDIR/certs/${filebase}.crt"    "$SSLDIR/certs/${filebase}_${olddate}.crt"
[ -f "$SSLDIR/private/${filebase}.key" ]  && mv "$SSLDIR/private/${filebase}.key"  "$SSLDIR/private/${filebase}_${olddate}.key"
[ -f "$SSLDIR/private/${filebase}.p12" ]  && mv "$SSLDIR/private/${filebase}.p12"  "$SSLDIR/private/${filebase}_${olddate}.p12"
[ -f "$SSLDIR/templates/${filebase}" ]    && rm -f "$SSLDIR/templates/${filebase}"

