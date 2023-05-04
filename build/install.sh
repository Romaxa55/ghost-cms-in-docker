#!/bin/bash
set -eux
# save list of currently installed packages for later so we can clean up
savedAptMark="$(apt-mark showmanual)"
apt-get update
apt-get install -y --no-install-recommends ca-certificates gnupg wget
rm -rf /var/lib/apt/lists/*

dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"
wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"
wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"

# verify the signature
export GNUPGHOME="$(mktemp -d)"
gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu
gpgconf --kill all
rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc

# clean up fetch dependencies
apt-mark auto '.*' > /dev/null
[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

chmod +x /usr/local/bin/gosu
# verify that the binary works
gosu --version
gosu nobody true
