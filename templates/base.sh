# OpenSSL Bash Warper - base script
# https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper

# Set common variables
export SSLDIR="$(cd $(dirname $0)/.. && pwd)"
export CANAME="${SSLDIR##*/}"

if [[ -L "$0" ]]; then
  export CN="$(basename $0)"
else
  export CN="${SSLDIR##*/}"
fi

export CANAME="${SSLDIR##*/}"
export OPENSSL_CONF="$SSLDIR/openssl.cnf"
[[ $SAN ]] || export SAN=''

# Clean uncompleted operations
for f in "$SSLDIR/requests/$(basename $0).csr" "$SSLDIR/private/$(basename $0).key" "$SSLDIR/certs/$(basename $0).crt" "$SSLDIR/private/$(basename $0).p12"
do
  if [[ -f "$f" ]]; then
    if [[ ! -s "$f" ]]; then
      rm -f "$f"
    fi
  fi
done

# Log executed command to history
base="\tCMD: $(basename $0)"
[[ -L "$0" ]] && script="\tSCRIPT: $(readlink $0)"
echo -e "[$(date +'%Y-%m-%d %H:%M:%S')]${script}${base} $@\nSAN=\"$SAN\"" >> "$(dirname $0)/history.log"

