#!/bin/env bash

#set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

get_url () {
    local product=
    local os="$1"
    local lang='en-US'

    case "$2" in esr) product='firefox-esr-latest' ;;
        stable) product='firefox-latest' ;;
        beta) product='firefox-beta-latest' ;;
        *)
            printf 'invalid channel: %s\n' "$2" >&2
            return 1
            ;;
    esac

    printf '%s?product=%s&os=%s&lang=%s' \
        'https://download.mozilla.org/' \
        "$product" \
        "$os" \
        "$lang"

    return 0

}

get_real_url () {

    wget -O - --max-redirect=0 "$(get_url "$@")" 2>&1 \
        | grep '^Location' \
        | cut -d ' ' -f 2

    return 0

}

reformat_version () {

    local version=; read version

    if ! [ "${version%esr}" = "$version" ]; then
        printf '%s' "${version%esr}"
    elif ! [ "${version//b}" = "$version" ]; then
        printf '%s_beta%d' "${version%%b*}" "${version##*b}"
    else
        printf '%s' "$version"
    fi

    return 0

}

get_version () {

    get_real_url "$@" \
        | rev \
        | cut -d '-' -f 1 \
        | cut -d '.' -f 3- \
        | rev \
        | reformat_version

    return 0

}

link_ebuild () {

    ln -v -s -- "${1##*/}" "firefox-channels-$2.ebuild"
    git add "firefox-channels-$2.ebuild"

}

main () {

    local base="$(cd "${BASH_SOURCE%/*}" && pwd)/www-client/firefox-channels"
    pushd "$base" >/dev/null 2>&1

        # delete symlinks
        find . -type l -name '*.ebuild' -exec bash -c \
            'git rm -f "$0" || rm -vf "$0"' {} \;

        # find original ebuild
        local ebuild=
        ebuild="$(find "$base" -type f -name '*.ebuild')"

        # move ebuild to new stable version
        local version=
        version="$(get_version 'linux' 'stable')"
        local new_ebuild="$base/firefox-channels-$version.ebuild"
        if ! [ "$new_ebuild" = "$ebuild" ]; then
            git mv -- "$ebuild" "$new_ebuild" \
                || mv -v -- "$ebuild" "$new_ebuild"
            ebuild="$new_ebuild"
        else
            git add "$ebuild"
        fi

        # create beta symlinks
        link_ebuild "$ebuild" "$(get_version 'linux' 'beta')"

        # create esr symlink and fix condition
        local esr_version=
        esr_version="$(get_version 'linux' 'esr')"
        link_ebuild "$ebuild" "$esr_version"
        sed -i -re "s/^(elif \[\[ [^']+')[^']+('.*)$/\1$esr_version\2/" \
            -- "$ebuild"

    popd >/dev/null 2>&1

}

main
