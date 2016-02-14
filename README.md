OpenSSL Bash Warper
===================

This tool comes as a few bash scripts to simplify the process of making your own X.509 Certificate Authority. It includes:

- Initialization script to generate a self signed RootCA
- Templates for client and server certificates
- Maximum flexibility by passing parameters to `openssl ca` utility
- Supports Subject Alternative Names (SAN) in server certificates
- Easy to use. Just create symlink to your desired template script
- Revocation template for client and server certificates,
  including management of Certificate Revocation Lists (CRL)
- Can build infinite chains of Intermediate CAs by copying
  instances of itself to sub directories
- Logs executed scripts to history file


Requirements
------------
- OpenSSL >= 1.0.1
- Bash >= 4.3
- Git >= 2.1

License
---------
```
OpenSSL Bash Warper is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

OpenSSL Bash Warper is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty
of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with OpenSSL Bash Warper. If not, see
<http://www.gnu.org/licenses/>.
```

Installation
------------

Clone the Git repository to your home directory.
```
cd ~
git clone 'https://github.com/SlashDashAndCash/OpenSSL-Bash-Warper.git'
```

Rename directory to your CA name, e.g. yourname-root-x1
```
mv OpenSSL-Bash-Warper yourname-root-x1
cd yourname-root-x1
```

### OpenSSL Configuration
It's strongly recommended to customize the openssl.cnf file

`cp openssl_example.cnf openssl.cnf`

Replace the properties with your settings.
- crlbaseurl
- countryName_default
- stateOrProvinceName_default
- 0.organizationName_default
- organizationalUnitName_default


### Initialize Root CA
Creating the root ca is quite easy.
`./templates/rootca.sh`

By default this will create a 4096 bits RSA key singed with SHA-512 signatures with a lifetime of ten years.
You may change this behavior by adding parameters.

| Key pair           | Digest    | Validity     |
| ------------------ |:---------:|:------------:|
| `-newkey rsa:2048` | `-sha256` | `-days 1825` |
| `-newkey rsa:3072` | `-sha512` | `-days 7300` |


See `man req` for details.


Create server and user certificates
-----------------------------------

You can create a certificate by just creating a symbolic link to the desired template script.

Server certificate: `ln -s server_template.sh templates/hostname.domain`

User certificate: `ln -s user_template.sh templates/username`

Then execute the link to create a new key, certificate signing request (csr) and a signed certificate.

`./templates/hostname.domain`

If you already have a signing request, copy it to the *requests* directory.
Filename must be the symbolic link with .csr extension.
```
vim requests/hostname.domain.csr
./templates/hostname.domain
```

You may want to add *subject alternative names* to a server certificate.
```
export SAN='DNS:hostname.domain,DNS:hostname,IP:8.8.8.8,IP:8.8.4.4'
./templates/hostname.domain
export SAN=''
```

You can also provide extra parameters to signing command (openssl ca) regardless of server or user certificate

`./templates/hostname.domain -option1 --option2 value --option3`

See `man ca` for available options.


Revoke a certificate
--------------------

Replace the symbolic link with the revocation template.
```
ln -s -f revoke_template.sh templates/hostname.domain
./templates/hostname.domain
```

This will also create a new certificate revocation list (crl).

`cat crl/yourname-root-x1.crl`


Create an intermediate CA
-------------------------

InterCAs are not self signed but signed by the root ca or another inter ca.
```
./templates/interca.sh yourname-caname-x1
cd yourname-caname-x1
```

Inter ca keys always have a 4096 modulus. Modify the interca.sh script to change this behavior.
You may provide extra parameters to signing command (openssl ca).

| Digest       | Validity     |
| ------------ |:------------:|
| `-md sha256` | `-days 1825` |
| `-md sha512` | `-days 3650` |

See `man ca` for available options.

You can run the *interca.sh* script within an inter ca directory to extend the chain of trust.


History log
-----------
All executed scripts will be logged in *./templates/history.log* relative to the ca directory.


Troubleshooting
---------------

If you run into an error, the template script interrupts and you have to clean up.

For user and server certificates you can use the archive script.

`./templates/archive.sh hostname.domain`

`./templates/archive.sh username`

If the *interca.sh* script failes, you should remove the unfinished inter ca directory.

`rm -rf yourname-caname-x1/`

If the *interca.sh* script failes after signing, you must also remove the last entry from *index.txt*.

