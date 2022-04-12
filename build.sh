#!/bin/sh

SOURCES=$(ls src/*.vala)

valac -C $SOURCES --pkg gio-2.0 --pkg gee-0.8
valac -g -c $SOURCES --header src/libvalajson.h --library libvalajson --pkg gio-2.0 --pkg gee-0.8 --vapi=libvalajson.vapi
ar rcs libvalajson.a *.o
cp src/libvalajson.h .
