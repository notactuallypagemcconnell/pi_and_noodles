#!/bin/bash

if [ $# -eq 0 ]
then
	echo "How come things that happen to stupid people, keep happening to me?"
else
	exec "$@"
fi
