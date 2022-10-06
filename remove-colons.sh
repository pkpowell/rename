#!/bin/bash
LC_CTYPE=en_US.utf8

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

# chars to remove (incl backslash!)
# chars='[\\\\.,? ]'
chars='[:]'

rgx="*${chars}*"
repl=$(printf '\uf022')

find_cmd=(
    find
    .
    -depth 
    #-type d
    -name "$rgx"
    -print0 # delimit output with NUL characters
)

shopt -s extglob 
                           # turn on extended glob syntax
while IFS= read -r -d '' source; do

    if [[ "$source" != "." ]]; then 
		target=${source##*/}
        dest="${target//:/$repl}"
        #echo "target $target"
        #echo "dest $dest"
        
        if [ "$d_flag" = true ];then
            echo "Changing $source to $dest"
            mv -- "$source" "$dest"
        else 
            echo "source $source dest $dest" 
        fi

    fi

done < <("${find_cmd[@]}") 