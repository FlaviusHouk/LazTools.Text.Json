#!/bin/sh

SOURCES=$(ls src/*.vala)

valac -c $SOURCES --header libvalajson.h --library libvalajson --pkg gio-2.0 --pkg gee-0.8 --vapi=libvalajson.vapi
ar rcs libvalajson.a *.o
