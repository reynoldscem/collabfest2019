#!/bin/bash

set -o errexit
defaults=(sour gose saison weisse cloudwater)


if [[ $# -eq 0 ]] || [[ $1 == "---" ]]; then
    URL="https://www.brewdog.com/blog/collabfest2019-beers"
    BEER_LIST=$(lynx -dump "$URL" | \
        awk '/:-/ {seen = 1} /list below/ {seen = 0} seen {print}' | \
        sed -e 's/^[[:space:]]*//' | \
        sed '1,2d' | \
        awk 'FNR%2' | \
        awk '{print} NR % 2 == 0 {print "";}')
    [[ $1 == "---" ]] && shift 1
elif [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
    echo "Use no arguments or first argument of '---' to download beer list."
    echo "Otherwise first argument is file of beers containing" \
        "repeating lines of brewery, beer, blankline."
    echo "Subsequent arguments are keywords to search for." \
        "Otherwise defaults are used."
    default_string=$(printf "%s, " "${defaults[@]^}")
    default_string="${default_string%, }"
    echo "Defaults are ${default_string}."
    exit 1
else
    if [[ -f "$1" ]]; then
        BEER_LIST=$(cat "$1")
        shift 1
    else
        echo "$1 is not a valid file!"
        echo "Use -h or --help for help."
    fi
fi
BEER_LIST=$(awk -v RS="" -F '\n' '{print $1"_;_"$2}' <<< "$BEER_LIST")

grep_arguments=("-i")
if [[ $# -gt 0 ]]; then
    search_terms=("$@")
else
    search_terms=("${defaults[@]}")
fi

for term in "${search_terms[@]}"; do
    grep_arguments+=("-e" "$term")
done

grep "${grep_arguments[@]}" <<<"$BEER_LIST" | \
    column -t -s "_;_" | \
    awk '{print $0} END{print "\n"NR " interesting beers.";}'
