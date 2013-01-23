#!/bin/sh

while socat TCP-LISTEN:8080,reuseaddr EXEC:./servidor.sh ; do
	true
done
