#!/bin/bash

speedInHertz=$(vcgencmd measure_clock arm)
echo speedInHertz