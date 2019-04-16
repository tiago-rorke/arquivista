#!/bin/bash

#always update git
git --git-dir=/home/pi/arquivista pull

#then run app using processing-java
processing-java --sketch=/home/pi/arquivista/arquivista_v1 --present

