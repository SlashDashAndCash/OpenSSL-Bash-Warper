# OpenSSL Bash Warper - PKCS#12 script
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

# Public-Key Cryptography Standards (PKCS#)
if [[ ! -f "$SSLDIR/private/$(basename $0).p12" ]]; then
  if [[ -f "$SSLDIR/certs/$(basename $0).crt" ]]; then
    if [[ -f "$SSLDIR/private/$(basename $0).key" ]]; then
      echo -e "\n*** Creating PKCS#12 file\n"

      # Create chain file
      cat "$SSLDIR/certs/ca.crt" > "$SSLDIR/certs/chain.tmp"
      if [[ -f "$SSLDIR/certs/ca-chain_"*.crt ]]; then
        cat "$SSLDIR/certs/ca-chain_"*.crt >> "$SSLDIR/certs/chain.tmp"
      fi

      openssl pkcs12 -export -in "$SSLDIR/certs/$(basename $0).crt" \
        -inkey "$SSLDIR/private/$(basename $0).key" \
        -certfile "$SSLDIR/certs/chain.tmp" \
        -name "$(basename $0)" \
        -keypbe AES-256-CBC -certpbe AES-256-CBC \
        -out "$SSLDIR/private/$(basename $0).p12"

      if [[ -e "$SSLDIR/private/$(basename $0).p12" ]]; then
        chmod 600 "$SSLDIR/private/$(basename $0).p12"

        # Delete p12 file after error
        [[ -s "$SSLDIR/private/$(basename $0).p12" ]] || rm -f "$SSLDIR/private/$(basename $0).p12"
      fi

      # Delete chain file
      [[ -e "$SSLDIR/certs/chain.tmp" ]] || rm -f "$SSLDIR/certs/chain.tmp"

    else
      echo -e "\n*** No key file found. Skipping PKCS#12\n"
    fi
  else
    echo -e "\n*** No certificate file found. Skipping PKCS#12\n"
  fi
else
  echo -e "\n*** PKCS#12 file already exists! Create manually.\n"
fi

