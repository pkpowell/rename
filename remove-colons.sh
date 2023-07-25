#!/usr/bin/env bash

LANGUAGE=en_US.UTF-8
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8

d_flag=''
v_flag=''

print_usage() {
  printf "Usage: -d make changes, -v verbose, -h help"
}

while getopts 'dvh' flag; do
  case "${flag}" in
    d) d_flag=true
       shift 1 ;;
    v) v_flag=true 
       shift 1 ;;
    h | *) print_usage
       exit 1 ;;
  esac
done

repl=$(printf '\uf022')

# args=("$@")
# if [[ ${#args[@]} -gt 0 ]];then
#     echo "args ${args[@]}"
#     if [[ -d "${args[0]}" ]];then
#         if [ "$d_flag" = true ];then
#             echo "repairing ${args[0]}"
#             mv -- "${args[0]}" "${args[0]//:/$repl}"
#         else
#             echo "pre ${args[0]} post ${args[0]//:/$repl}"
#         fi
#         exit 0
#     fi
# fi

chars='[:]'
count=0
rgx="*${chars}*"

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

        ((count++))

        if [ "$d_flag" = true ];then
            if [ "$v_flag" = true ];then
                echo "Changing $source to $dest"
                echo
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

source=$(pwd)
target=${source##*/}
path=${source%/*}
dest="${path}/${target//:/$repl}"

if [ "$d_flag" = true ];then
    if [ "$v_flag" = true ];then
        echo "Changing $source to $dest"
        echo
    fi
    mv -- "${source}" "${dest}"
else 
    if [ "$v_flag" = true ];then
        echo "source ${source}" 
        echo "dest ${dest}" 
        echo
    fi
fi

if [ "$d_flag" = true ];then
    echo "Repaired ${count} instances"
else
    echo "Found ${count} instances"
fi
