#!/bin/bash
if [ $(pidof compton) ]; then
	killall compton
else
	compton -b
fi
