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

find_regex="*${chars}*"
replacement=$(printf '\uf022')

find_cmd=(
    find
    .
    -depth 
    -type d
    -name "$find_regex"
    -print0 # delimit output with NUL characters
)

shopt -s extglob 
                           # turn on extended glob syntax
while IFS= read -r -d '' source_name; do

    if [[ "$source_name" != "." ]]; then 
		target_dir=${source_name##*/}
        dest_name="${target_dir//:/${replacement}}" # replace ":"
        #echo "dest $dest_name"
        
        if [ "$d_flag" = true ];then
            echo "Changing $source_name to $dest_name"
            mv -- "$source_name" "$dest_name"
        else 
            echo "source $source_name dest $dest_name" 
        fi

    fi

done < <("${find_cmd[@]}") 