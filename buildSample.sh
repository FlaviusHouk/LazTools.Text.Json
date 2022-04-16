#!/bin/sh

valac -C sample.vala --vapidir=$PWD --pkg libvalajson --pkg gee-0.8 --pkg gio-2.0
valac -g -c sample.vala --vapidir=$PWD --pkg libvalajson --pkg gee-0.8 --pkg gio-2.0 -X -I$PWD
gcc $(pkg-config --libs gee-0.8) $(pkg-config --libs gio-2.0) sample.vala.o libvalajson.a -o sample
