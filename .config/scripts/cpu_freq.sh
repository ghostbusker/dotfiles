#!/bin/bash

vcgencmd measure_clock arm | rev | cut -c 10- | rev | sed 's/$/GHz/' $0
