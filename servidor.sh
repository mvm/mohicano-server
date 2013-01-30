#!/bin/sh

SERVER="Mohicano"

read -r line
request=$(echo $line | tr -d "\r" )
content_length=0
content_type=""

while [ "$line" != "" ]
do
	if ( echo $line | grep -iq "content-length" )
	then
		content_length=$(echo $line | cut -d " " -f 2 )
	fi
	read line
	line=$(echo $line | tr -d "\r" )
done

method=$(echo $request | awk '{ print $1 }' )
file=".$(echo $request | awk '{ print $2 }' | sed -e 's/\.\.//g')"
proto=$(echo $request | awk '{ print $3 }' )
param=$(echo $file | sed -e 's/^[^?]*?//' )
file=$(echo $file | sed -e 's/?.*$//' )

if [ $content_length -gt 0 ] ; then
	param=$(dd bs=$content_length count=1 2>/dev/null )
fi

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
echo -n "$method $file " >/dev/stderr

if [ -f "$file" -a $( echo $file | grep ".py" ) ] ; then
	echo "200 OK" >/dev/stderr
	echo "HTTP/1.1 200 OK"
	echo -n "Date: "
	LC_ALL="en" date
	echo "Server: $SERVER"
	SERVER_PROTOCOL="$proto" REQUEST_METHOD="$method" QUERY_STRING="$param" REQUEST_METHOD="GET" python "$file"
elif [ -f "$file" ] ; then
	send_file "$file" "200 OK"
elif [ -d "$file" ] ; then
	header "202 OK" "text/plain"
	ls -lh "$file" | gzip
else
	send_file "./404.html" "404 Not Found"
fi
