# Copyright (c) 2010, Huy Nguyen, http://www.huyng.com
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided
# that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice, this list of conditions
#       and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
#       following disclaimer in the documentation and/or other materials provided with the distribution.
#     * Neither the name of Huy Nguyen nor the names of contributors
#       may be used to endorse or promote products derived from this software without
#       specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


# USAGE:
# s bookmarkname - saves the curr dir as bookmarkname
# g bookmarkname - jumps to the that bookmark
# g b[TAB] - tab completion is available
# p bookmarkname - prints the bookmark
# p b[TAB] - tab completion is available
# d bookmarkname - deletes the bookmark
# d [TAB] - tab completion is available
# l - list all bookmarks

# setup file to store bookmarks
if [ ! -n "$SDIRS" ]; then
    SDIRS=~/.sdirs
fi
touch "$SDIRS"
export SDIRS

RED="0;31m"
GREEN="0;33m"

# save current directory to bookmarks
function s {
    check_help $1
    if _bookmark_name_valid "$@"; then
        echo "$1=$(pwd)" >> "$SDIRS"
        echo "baskmark saved!"
    fi
}

# jump to bookmark
function g {
    check_help $1
    target=$( egrep "^$@=" "$SDIRS" | sed -E "s:^$@=::" )
    if [ -d "$target" ]; then
        cd "$target"
    elif [ ! -n "$target" ]; then
        echo -e "\033[${RED}WARNING: '${1}' bashmark does not exist\033[00m"
    else
        echo -e "\033[${RED}WARNING: '${target}' does not exist\033[00m"
    fi
}

# delete bookmark
function d {
    check_help $1
    if _bookmark_name_valid "$@"; then
        _purge_line "$SDIRS" "$1="
        echo "baskmark removed."
    fi
}

# print out help for the forgetful
function check_help {
    if egrep -q '^\-\-?h(elp)?$' <<< "$1"; then
        echo ''
        echo 's <bookmark_name> - Saves the current directory as "bookmark_name"'
        echo 'g <bookmark_name> - Goes (cd) to the directory associated with "bookmark_name"'
        echo 'd <bookmark_name> - Deletes the bookmark'
        echo 'l                 - Lists all available bookmarks'
        kill -SIGINT $$
    fi
}

# list bookmarks with dirnam
function l {
    check_help $1
    while read line; do
        printf "\033[0;33m%10s\033[0m  %s\n" "${line%%=*}" "${line#*=}" | sed "s:$HOME:~:"
    done < <(cat "$SDIRS" | sort)
}

# validate bookmark name
function _bookmark_name_valid {
    ret=0
    exit_message=
    if [ -z "$1" ]; then
        exit_message="bookmark name required"
        ret=1
    elif [ "$1" != "$(echo $1 | sed 's/[^A-Za-z0-9_]//g')" ]; then
        exit_message="bookmark name is not valid"
        ret=2
    elif egrep -q "^$1=" "$SDIRS"
        exit_message="bookmark name already exists."
        ret=4
    fi
    echo $exit_message
    return $ret
}

# completion command
# function _comp {
#     local curw
#     COMPREPLY=()
#     curw=${COMP_WORDS[COMP_CWORD]}
#     COMPREPLY=($(compgen -W '`_l`' -- $curw))
#     return 0
# }

# ZSH completion command
# function _compzsh {
#     reply=($(_l))
# }

# safe delete line from sdirs
function _purge_line {
    if [ -s "$1" ]; then
        # safely create a temp file
        t=$(mktemp -t bashmarks.XXXXXX) || return 1
        trap "rm -f -- '$t'" EXIT

        # purge line
        sed "/$2/d" "$1" > "$t"
        mv "$t" "$1"

        # cleanup temp file
        rm -f -- "$t"
        trap - EXIT
    fi
}

# bind completion command for g,p,d to _comp
# if [ $ZSH_VERSION ]; then
#     compctl -K _compzsh g
#     compctl -K _compzsh p
#     compctl -K _compzsh d
# else
#     shopt -s progcomp
#     complete -F _comp g
#     complete -F _comp p
#     complete -F _comp d
# fi
