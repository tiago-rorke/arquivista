#!/bin/bash

#always update git
( cd /home/pi/arquivista && git pull )

#then run app using processing-java
processing-java --sketch=/home/pi/arquivista/arquivista_v1 --present

