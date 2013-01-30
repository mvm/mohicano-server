#!/bin/sh

SERVER="Mohicano"

read -r request

method=$(echo $request | awk '{ print $1 }' )
request=$(echo $request | awk '{ print $2 }' | sed -e 's/\.\.//g')
proto=$(echo $request | awk '{ print $3 }' )
file=".$request"
param=$(echo $file | sed -e 's/^[^?]*?//' )
file=$(echo $file | sed -e 's/?.*$//' )

header() {
	status="$1"
	type="$2"
	echo "$status" >/dev/stderr
	echo "HTTP/1.1 $status"
	echo -n "Date: "
	LC_ALL="en" date
	echo "Server: $SERVER"
	echo "Content-Encoding: gzip"
	echo "Content-Type: $type"
	echo
}

send_file() {
	f="$1"
	type=$(file -bi "$f")
	header "$2"  "$type"
	cat "$f" | gzip
}

if [ "$file" = "./" ] ; then
	file="./index.html"
fi

echo -n "[$(date)] " >/dev/stderr
echo -n "$method $file $param " >/dev/stderr

if [ -f "$file" -a $( echo $file | grep ".py" ) ] ; then
	echo "200 OK" >/dev/stderr
	echo "HTTP/1.1 200 OK"
	echo -n "Date: "
	LC_ALL="en" date
	echo "Server: $SERVER"
	SERVER_PROTOCOL="$proto" REQUEST_METHOD="GET" QUERY_STRING="$param" REQUEST_METHOD="GET" python "$file"
elif [ -f "$file" ] ; then
	send_file "$file" "200 OK"
elif [ -d "$file" ] ; then
	header "202 OK" "text/plain"
	ls -lh "$file" | gzip
else
	send_file "./404.html" "404 Not Found"
fi
