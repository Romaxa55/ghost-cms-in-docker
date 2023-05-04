#!/bin/bash
set -eux
mkdir -p "$GHOST_INSTALL"
chown node:node "$GHOST_INSTALL"

savedAptMark="$(apt-mark showmanual)"
aptPurge=

installCmd='gosu node ghost install "$GHOST_VERSION" --db mysql --dbhost mysql --no-prompt --no-stack --no-setup --dir "$GHOST_INSTALL"'
if ! eval "$installCmd"; then
    aptPurge=1
    apt-get update
    apt-get install -y --no-install-recommends g++ make python3
    eval "$installCmd"
fi

# Tell Ghost to listen on all ips and not prompt for additional configuration
cd "$GHOST_INSTALL"
# prompt --ip '::' --port 2368 --url 'http://localhost:2368'
gosu node ghost config paths.contentPath "$GHOST_CONTENT"

# make a config.json symlink for NODE_ENV=development (and sanity check that it's correct)
gosu node ln -s config.production.json "$GHOST_INSTALL/config.development.json"
readlink -f "$GHOST_INSTALL/config.development.json"

# need to save initial content for pre-seeding empty volumes
mv "$GHOST_CONTENT" "$GHOST_INSTALL/content.orig"
mkdir -p "$GHOST_CONTENT"
chown node:node "$GHOST_CONTENT"
chmod 1777 "$GHOST_CONTENT"

# force install a few extra packages manually since they're "optional" dependencies
cd "$GHOST_INSTALL/current"
packages="$(node -p ' \
    var ghost = require("./package.json"); \
    var transform = require("./node_modules/@tryghost/image-transform/package.json"); \
    [ \
        "sharp@" + transform.optionalDependencies["sharp"], \
        "sqlite3@" + ghost.optionalDependencies["sqlite3"], \
    ].join(" ") \
')"

if echo "$packages" | grep 'undefined'; then exit 1; fi
for package in $packages; do
    installCmd='gosu node yarn add "$package" --force'
    if ! eval "$installCmd"; then
        aptPurge=1
        apt-get update
        apt-get install -y --no-install-recommends g++ make python3
        case "$package" in
            sharp@*) echo >&2 "sorry: libvips 8.10 in Debian bullseye is not new enough (8.12.2+) for sharp 0.30 😞"; continue ;;
        esac
        eval "$installCmd --build-from-source"
    fi
done

if [ -n "$aptPurge" ]; then
    apt-mark showmanual | xargs apt-mark auto > /dev/null
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark
    apt-get purge -y --auto-remove
    rm -rf /var/lib/apt/lists/*
fi

gosu node yarn cache clean
gosu node npm cache clean --force
npm cache clean --force
rm -rv /tmp/yarn* /tmp/v8*
