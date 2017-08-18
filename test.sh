#! /bin/bash

echo $1 \
	| grep -v 'Type'\
	| awk '{print $NF}' \
	| tr ':' ' ' \
	| xargs printf '%s*60+%s+' \
	| sed -E 's/^(.*)\+$/\scale=2;(\1\)\/3600\n/' \
	| bc
