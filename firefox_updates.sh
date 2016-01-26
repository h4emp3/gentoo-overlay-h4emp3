#!/usr/bin/env zsh

#
# 26. January 2016
#
#   Mozilla deployed a new downloads api which replaces the latest
#   folders/symlinks for binary builds on ftp.mozilla.org.
#   The API works by returning a 302 to a file when requesting
#   https://download.mozilla.org with three get parameters.
#
#   Currently it supports stable, beta and aurora for linux/linux64. For some
#   reason the API supports SSL download links _only_ for aurora-latest. For
#   stable and beta the SSL links only work with an explicit version.
#
#   GET Params:
#       - product
#           - firefox-<channel>-(<version>|latest)[-ssl]
#       - os
#           - (linux|linux64)
#       - lang
#           - any language code (e.g. en-US)
#

setopt nounset errexit warncreateglobal

local -ra targets=(source binary)
local -ra channels=(stable beta aurora)
local -ra archs=(x86 amd64)
# firefox urls and file filters {{{

local -r base_url='https://ftp.mozilla.org/pub/firefox'

local -r stable_source_x86="${base_url}/releases/latest/source/"
local -r stable_source_x86_filter='[0-9]\.source\.tar\.xz$'
local -r stable_source_amd64="${base_url}/releases/latest/source/"
local -r stable_source_amd64_filter="$stable_source_x86_filter"

local -r beta_source_x86="${base_url}/releases/latest-beta/source/"
local -r beta_source_x86_filter="$stable_source_x86_filter"
local -r beta_source_amd64="${base_url}/releases/latest-beta/source/"
local -r beta_source_amd64_filter="$stable_source_amd64_filter"

# }}}

# path to search ebuilds
local -r portage_path="$(cd ${${(%):-%x}%/*} && pwd)"

# external dependencies
local -ra dependencies=(wget grep sort tail git repoman rm ln)

# general shell helpers
# function _ {  cli logger {{{

local -rA log_levels=(
    debug 0
    info 1
    warning 2
    error 3
)

declare -gA colors
function {  # fill array 'colors' with color escape sequences {{{

    local -r color_prefix=$'\033['
    local -r color_suffix='m'
    local -A color_codes=(
        reset 0
        bold 1
        nobold 21
        black 30
        red 31
        green 32
        yellow 33
        blue 34
        magenta 35
        cyan 36
        white 37
    )

    local name value
    for name value in ${(@kv)color_codes}; do
        colors[${name}]="${color_prefix}${value}${color_suffix}"
    done

}  # }}}

function _ {

    local level="$1"
    local fstr="$2"

    shift 2

    local color=

    # replace %q with colored quotes
    fstr="${fstr//%q/${colors[black]}${colors[bold]}\'${colors[reset]}%s${colors[black]}${colors[bold]}\'}"

    # prepend * colored depending on log message level
    if [ "${log_levels[$level]}" -eq "${log_levels[debug]}" ]; then
        if [ "${DEBUG-false}" = false ]; then
            return 0
        fi
        color='white'
    elif [ "${log_levels[$level]}" -eq "${log_levels[info]}" ]; then
        color='green'
    elif [ "${log_levels[$level]}" -eq "${log_levels[warning]}" ]; then
        color='yellow'
    elif [ "${log_levels[$level]}" -eq "${log_levels[error]}" ]; then
        color='red'
    else
        _ 'warning' 'unknown log level %q' "$level"
    fi
    fstr="${colors[$color]}${colors[bold]} * ${colors[reset]}${colors[black]}${colors[bold]}${fstr}"

    # evaluate fstr with remaining args
    print -f "${fstr}${colors[reset]}" -- $@ >&2

}  # }}}
function require_prog {  # returns 1 and prints error if $1 is not a valid executable {{{

    local prog="$1"

    if ! which "$prog" >/dev/null 2>&1; then
        _ 'error' 'dependency %q not found\n' "$prog"
        return 1
    fi

}  # }}}
function require_progs {  # returns 1 if any of $@ is not a valid executable {{{

    local prog=

    local satisfied='true'

    for prog in $@; do
        if ! require_prog "$prog"; then
            satisfied='false'
        fi
    done

    if ! [ "$satisfied" = 'true' ]; then
        return 1
    fi

}  # }}}
function contains {  # returns 1 if $1 is not in ${@:2} {{{

    local elem=

    for elem in "${@:2}"; do
        if [ "$elem" = "$1" ]; then
            return 0
        fi
    done

    return 1

}  # }}}
function fetch_url {  # downloads $1 and prints it to stdout {{{

    local url="$1"

    wget --quiet --output-document - "$url"

}  # }}}
function redirect_symlink {  # changes to target of a symlink {{{

    local link="$1"
    local new_target="$2"

    local target="$(readlink -f "$link")"

    if [ "$target" = "$new_target" ]; then
        return 0
    fi

    _ 'debug' 'redirecting symlink %q to %q\n' "$link" "$new_target"
    _ 'debug' "$(rm -vf -- "$link")\n"
    _ 'debug' "$(ln -vs -- "$new_target" "$link")\n"

}  # }}}

# general script helpers
function run {  # {{{

    _ 'debug' "$(
        print -- "run \033[30;1m'\033[0m";
        print -f '%s ' -- $@;
        print -- "\033[1D\033[30;1m'\033[0m";
    )\n"

    $@

}  # }}}
function _git {  # run git in portage_path {{{

    pushd "$portage_path" >/dev/null
        _ 'debug' "$(run git $@)\n"
    popd >/dev/null

}  # }}}
function version__to_ebuild {  # converts intermediate version format to ebuild format {{{

    local version="$1"

    version="${version/a/_alpha}"
    version="${version/b/_beta}"

    print -n -- "$version"

}  # }}}

# helpers to get archive information (same format as ebuild)
function archive_file_links {  # API 'client' {{{

    local channel="$1"
    local arch="$2"

    local url="https://download.mozilla.org/?product=firefox"
    [ "$channel" = 'stable' ] || url="${url}-${channel}"
    url="${url}-latest&os=linux"
    [ "$arch" = 'amd64' ] && url="${url}64"
    url="${url}&lang=en-US"

    local location="$(wget --max-redirect=0 "$url" 2>&1 \
        | grep '^Location: ' \
        | cut -d ' ' -f 2)"

    [ -n "$location" ] || return 1

    print -- "$location"

}  # }}}
function archive_source_file_links {  # html parser, source only {{{

    local url="$1"

    local line=
    local oldifs=
    local schema=
    local domain=

    schema="${url%%://*}"
    domain="${url/$schema:\/\/}"
    domain="${domain%%/*}"

    fetch_url "$url" | grep 'href' | while IFS=$'\n' read line; do

        # get contents of href
        line="${line#* href=\"}"
        line="${line%%\"*}"

        # skip directory links
        if [ "${line:$(( ${#line} - 1 )):1}" = '/' ]; then
            continue
        fi

        # append schema + domain
        line="$(print -f '%s://%s%s\n' -- "$schema" "$domain" "$line")"

        print -- "$line"

    done

}  # }}}
function archive_get_version {  # returns version part of given file url {{{

    local url="$1"

    local version=

    version="${url#*/firefox-}"
    version="${version/%\.[a-z]*}"

    print -n -- "$version"

}  # }}}
function archive_list {  # {{{

    local target="$1"
    local channel="$2"
    local arch="$3"

    if [ "$target" = 'binary' ]; then
        archive_file_links "$channel" "$arch" | while read url; do
            print -f 'binary : %s : %s : %s : %s\n' -- \
                "$channel" \
                "$arch" \
                "$(archive_get_version "$url")" \
                "$url"
        done
        return 0
    fi

    local filter_var="${channel}_${target}_${arch}_filter"
    local url_var="${channel}_${target}_${arch}"

    if [ -z "${(P)filter_var-}" ]; then
        _ 'error' 'filter not found %q\n' "$filter_var"
        return 1
    fi

    if [ -z "${(P)url_var-}" ]; then
        _ 'error' 'url not found %q\n' "$url_var"
        return 1
    fi

    _ 'debug' 'search archive for %q %q %q\n' \
        "$target" "$channel" "$arch"

    archive_source_file_links "${(P)url_var}" \
        | grep -E -- "${(P)filter_var}" \
        | sort --numeric \
        | tail --lines 1 \
        | while read url
    do
        print -f '%s : %s : %s : %s : %s\n' -- \
            "$target" \
            "$channel" \
            "$arch" \
            "$(archive_get_version "$url")" \
            "$url"
    done

}  # }}}

# dispatch identifiers channel, target and arch
function archive_dispatch_arch {  # calls 'archive_list' for arch being either $3 or every value in $archs {{{

    local target="$1"
    local channel="$2"
    local arch="${3-all}"

    if [ "$arch" = 'all' ]; then
        for arch in ${archs[@]}; do
            archive_list "$target" "$channel" "$arch" || continue
        done
    elif ! contains "$arch" ${archs[@]}; then
        _ 'error' 'unknown archive arch %q\n' "$arch"
        return 1
    else
        archive_list "$target" "$channel" "$arch"
    fi

}  # }}}
function archive_dispatch_channel {  # calls archive_dispatch_arch for channel being either $2 or every value in $targets {{{

    local target="$1"
    local channel="${2-all}"
    local arch="${3-all}"

    if [ "$channel" = 'all' ]; then
        for channel in ${channels[@]}; do
            archive_dispatch_arch "$target" "$channel" "$arch"
        done
    elif ! contains "$channel" ${channels[@]}; then
        _ 'error' 'unknown archive channel %q\n' "$channel"
        return 1
    else
        archive_dispatch_arch "$target" "$channel" "$arch"
    fi

}  # }}}
function archive_dispatch_target {  # calls archive_dispatch_channel for target being either $1 or every value in $channels {{{

    local target="${1-all}"
    local channel="${2-all}"
    local arch="${3-all}"

    if [ "$target" = 'all' ]; then
        for target in ${targets[@]}; do
            archive_dispatch_channel "$target" "$channel" "$arch"
        done
    elif ! contains "$target" ${targets[@]}; then
        _ 'error' 'unknown archive target %q\n' "$target"
        return 1
    else
        archive_dispatch_channel "$target" "$channel" "$arch"
    fi

}  #}}}

# helpers to get ebuild information (same format as archive)
function portage_get_versions {  # {{{

    local file="$1"

    local version="${file##*/}"
    version="${version%.ebuild}"
    version="${version/#[a-z-]*-}"

    local next="${version/_beta/b}"
    local channel=
    if ! [ "$next" = "$version" ]; then
        version="$next"
        channel='beta'
    else
        next="${version/_alpha/a}"
        if ! [ "$next" = "$version" ]; then
            version="$next"
            channel='aurora'
        else
            channel='stable'
        fi
    fi

    next="$(grep '^KEYWORDS=' "$file")"
    next="${next#*=}"
    next="${next#\"}"
    next="${next%\"}"
    next="${next//-\*}"
    next="${next//\~}"
    local -a keywords=(${(s: :)next})

    if [ -z "$keywords" ]; then
        return 0
    fi

    local arch=
    for arch in "${keywords[@]}"; do
        print -f '%s : %s : %s\n' -- "$channel" "$arch" "$version"
    done

}  # }}}
function portage_find_ebuilds {  # {{{

    local target="$1"

    local package_path="${portage_path}/www-client/firefox"
    local ebuild=

    if [ "$target" = 'binary' ]; then
        package_path="${package_path}-bin"
    fi

    if ! [ -d "$package_path" ]; then
        _ 'warning' 'package path for target %q not found: %q\n' "$target" "$package_path"
        return 0
    fi

    _ 'debug' 'search ebuilds in %q\n' "$package_path"

    find "${package_path}" -name '*.ebuild' | sort --numeric | while read ebuild; do
        print -f '%s : %s\n' -- "$target" "$ebuild"
    done

}  # }}}
function portage_list_ebuilds {  # {{{

    local target="${1-all}"

    if [ "$target" = 'all' ]; then
        for target in ${targets[@]}; do
            portage_find_ebuilds "$target"
        done
    elif ! contains "$target" ${targets[@]}; then
        _ 'error' 'unknown ebuild target %q\n' "$target"
        return 1
    else
        portage_find_ebuilds "$target"
    fi

}  # }}}

# functions for comparing archive with ebuilds
function find_updates {  # {{{

    local target="${1-all}"
    local channel="${2-all}"
    local arch="${3-all}"

    # format: <target>_<channel>_<arch> = <version> : <url>
    local -A archive
    function {  # read archive {{{

        local _target _channel _arch version url
        archive_dispatch_target "$target" "$channel" "$arch" \
            | while IFS=' : ' read -d $'\n' _target _channel _arch version url
        do
            archive[${_target}_${_channel}_${_arch}]="${version} : ${url}"
        done

    }  # }}}

    # format: <target>_<channel>_<arch> = <version> : <ebuild>
    local -A ebuilds
    function {  # read ebuilds {{{

        local _target= ebuild=
        portage_list_ebuilds "$target" "$channel" "$arch" | while IFS=' : ' read -d $'\n' _target ebuild; do
            local _channel= _arch= version=
            portage_get_versions "$ebuild" | while IFS=' : ' read -d $'\n' _channel _arch version; do
                ebuilds[${_target}_${_channel}_${_arch}]="${version} : ${ebuild}"
            done
        done

    }  # }}}

    local -a known_ebuilds

    local key=
    for key in ${(@ko)ebuilds}; do

        local ebuild="${ebuilds[$key]##* : }"
        local ebuild_version="${ebuilds[$key]%% : *}"

        if [ -z "${archive[$key]-}" ]; then
            _ 'debug' 'no match found in archive for %q\n' "$key"
            continue
        fi

        local url="${archive[$key]##* : }"
        local archive_version="${archive[$key]%% : *}"

        if ! [[ "$ebuild_version" < "$archive_version" ]]; then
            if ! contains "$ebuild" ${known_ebuilds[@]-}; then
                _ 'info' 'ebuild is up-to-date: %q\n' "$ebuild"
                known_ebuilds=(${known_ebuilds[@]-} $ebuild)
            fi
            continue
        fi

        _ 'info' "found update for %q: \033[30;1m'\033[31;1m%s\033[30;1m' -> \033[30;1m'\033[32;1m%s\033[30;1m'\n" \
            "${key//_/:}" "$ebuild_version" "$archive_version"

        print -f '%s : %s : %s : %s : %s\n' -- "${key//_/ : }" "$ebuild_version" "$ebuild" "$archive_version" "$url"

    done

}  # }}}

# actions
function cmd__list-archive {  # prints latest releases on mozilla archive mirror {{{

    local target="${1-all}"
    local channel="${2-all}"
    local arch="${3-all}"

    local _target _channel _arch version url
    archive_dispatch_target "$target" "$channel" "$arch" \
        | while IFS=' : ' read -d $'\n' _target _channel _arch version url
    do
        print -f "%s/%s/%s: %s - %s\n" -- "$_target" "$_channel" "$_arch" "$version" "$url"
    done | uniq

}  # }}}
function cmd__list-ebuilds {  # lists ebuilds in $portage_path {{{

    local target="${1-all}"

    local ebuild_target=
    local ebuild=
    local arch=
    local channel=
    local version=

    portage_list_ebuilds "$target" \
        | while IFS=' : ' read -d $'\n' ebuild_target ebuild
    do
        portage_get_versions "$ebuild" 2>/dev/null \
            | while IFS=' : ' read -d $'\n' channel arch version
        do
            _ 'info' "${ebuild%/*}/\033[0m${ebuild##*/}\n"
            print -f ' \033[30;1m-\033[0m %s = \033[0m%s\n' -- \
                'Target' "$ebuild_target" \
                'Channel' "$channel" \
                'Arch' "$arch" \
                'Version' "$version"
        done
    done

}  # }}}
function cmd__list-updates {  # search and list available updates for existing ebuilds {{{

    find_updates $@ >/dev/null

}  # }}}
function cmd__update {  # updates ebuilds automatically {{{

    local _target="${1-all}"
    local _channel="${2-all}"
    local _arch="${3-all}"

    local -A ebuilds_needing_update
    local -a paths

    # find updates {{{

    local update=
    local target=
    local channel=
    local arch=
    local ebuild_version=
    local ebuild=
    local archive_version=
    local url=

    find_updates "$_target" "$_channel" "$_arch" | while IFS=$'\n' read update; do
        IFS=' : ' read target channel arch ebuild_version ebuild archive_version url <<<"$update"
        archive_version="$(version__to_ebuild "$archive_version")"
        ebuild_version="$(version__to_ebuild "$ebuild_version")"
        if [ -z "${ebuilds_needing_update[$ebuild]-}" ]; then
            _ 'info' 'update for %q: %q -> %q\n' "$ebuild" "$ebuild_version" "$archive_version"
            ebuilds_needing_update[$ebuild]="${ebuild_version} : ${archive_version}"
            if ! contains "${ebuild%/*}" ${paths[@]-}; then
                paths=(${paths[@]-} ${ebuild%/*})
            fi
        elif ! [ "${ebuilds_needing_update[$ebuild]}" = "${ebuild_version} : ${archive_version}" ]; then
            _ 'error' 'different update for %q: %q -> %q\n' "$ebuild" "$ebuild_version" "$archive_version"
        fi
    done

    # }}}
    # do symlinks first to avoid breaking them {{{

    local ebuild=
    local old_version=
    local new_version=
    local new_file=

    for ebuild in ${(@k)ebuilds_needing_update}; do
        [ -L "$ebuild" ] || continue
        old_version="${ebuilds_needing_update[$ebuild]%% : *}"
        new_version="${ebuilds_needing_update[$ebuild]##* : }"
        new_file="${ebuild/${old_version}/${new_version}}"
        _ 'info' 'move ebuild %q\n' "$ebuild"
        _git mv -v -- "$ebuild" "$new_file"
        unset "ebuilds_needing_update[${ebuild}]"
    done

    # }}}
    # then do real files and fix symlinks on the way {{{

    local ebuild=
    local old_version=
    local new_version=
    local new_file=
    local file=

    for ebuild in ${(@k)ebuilds_needing_update}; do
        if [ -L "$ebuild" ]; then
            continue
        fi
        old_version="${ebuilds_needing_update[$ebuild]%% : *}"
        new_version="${ebuilds_needing_update[$ebuild]##* : }"
        new_file="${ebuild/${old_version}/${new_version}}"
        _ 'info' 'move ebuild %q\n' "$ebuild"
        _git mv -v -- "$ebuild" "$new_file"
        for file in ${ebuild%/*}/*.ebuild; do
            if ! [ -L "$file" ]; then
                continue
            fi
            if ! [ "$(readlink -f "$file")" = "$ebuild" ]; then
                continue
            fi
            _ 'info' 'fix symlink %q\n' "$file"
            redirect_symlink "$file" "$new_file"
            _git add -v -- "$file"
        done
    done

    # }}}
    # run repoman for every path {{{

    if [ -n "${paths-}" ]; then
        local _path=
        for _path in ${paths[@]}; do
            pushd "$_path" >/dev/null
                local file=
                for file in *.ebuild; do run ebuild "$file" digest manifest; done
                run sudo repoman --ask --digest y --verbose --include-dev --include-exp-profiles y --mode full --pretend
            popd >/dev/null
        done
    fi

    # }}}

}  # }}}

# autogenerated usage
function usage {  # {{{

    print -- '\nUsage:'
    print -f '  %s -h|--help\n' -- "${(%):-%x}"
    print -f '  %s <action>\n' -- "${(%):-%x}"
    print -f '  %s list-<action> [<target> [<channel> [<arch>]]]\n' -- "${(%):-%x}"
    print -- '\nActions:'

    local line=
    grep '^function cmd__' "${(%):-%x}" | while IFS=$'\n' read line; do
        line="${line#*cmd__}"
        local func="${line%% *}"
        line="${line##*  # }"
        local comment="${line% *}"
        comment="${comment//\(/\\\(}"
        comment="${comment//)/\\)}"
        print -f '  %s : %s\n' -- "$func" "$comment"
    done

    print -- '\nTargets:'
    print -f '  %s\n' -- ${targets[@]}

    print -- '\nChannels:'
    print -f '  %s\n' -- ${channels[@]}

    print -- '\nArchitectures:'
    print -f '  %s\n' ${archs[@]}

    print

}  # }}}

# argument dispatch
function main {  # {{{

    local cmd="${1-}"

    local func=

    if [ "$cmd" = '-h' ] || [ "$cmd" = '--help' ]; then
        usage
        return 0
    fi

    if [ -z "$cmd" ]; then
        usage
        _ 'error' 'not enough arguments\n'
        return 1
    fi

    func="cmd__${cmd}"
    shift 1

    if ! type "$func" >/dev/null 2>&1; then
        usage
        printf 'unknown action %s\n' "$cmd"
        return 1
    fi

    $func $@

}  # }}}

# check dependencies before calling anything
require_progs ${dependencies[@]}
# start program
main $@
