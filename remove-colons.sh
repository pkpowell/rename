#!/bin/bash
# LC_CTYPE=en_US.utf8

d_flag=''
verbose='false'

print_usage() {
  printf "Usage: -d make changes"
}

while getopts 'd' flag; do
  case "${flag}" in
    d) d_flag=true ;;
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
            echo "Changing $source to $dest"
            mv -- "${source}" "${dest}"
        else 
            echo "source ${source}" 
            echo "dest ${dest}" 
            echo
        fi

    fi

done < <("${find_cmd[@]}") 

echo "Found ${count} instances"
