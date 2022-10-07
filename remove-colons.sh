#!/usr/bin/env bash

LANGUAGE=en_US.UTF-8
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

d_flag=''
v_flag=''

print_usage() {
  printf "Usage: -d make changes, -v verbose"
}

while getopts 'dv' flag; do
  case "${flag}" in
    d) d_flag=true ;;
    v) v_flag=true ;;
    *) print_usage
       exit 1 ;;
  esac
done


chars='[:]'
count=0

rgx="*${chars}*"
repl=$(printf '\uf022')

find_cmd=(
    find
    .
    -depth 
    # -type f
    -name "$rgx"
    -print0 # delimit output with NUL characters
)

# turn on extended glob syntax
shopt -s extglob 

while IFS= read -r -d '' source; do

    if [[ "$source" != "." ]]; then 
        target=${source##*/}
        path=${source%/*}
        dest="${path}/${target//:/$repl}"
        # echo "target $target"
        # echo "dest $dest"
        ((count++))
        
        if [ "$d_flag" = true ];then
            if [ "$v_flag" = true ];then
                echo "Changing $source to $dest"
            fi
            mv -- "${source}" "${dest}"
        else 
            if [ "$v_flag" = true ];then
                echo "source ${source}" 
                echo "dest ${dest}" 
                echo
            fi
        fi

    fi

done < <("${find_cmd[@]}") 

echo "Found ${count} instances"
