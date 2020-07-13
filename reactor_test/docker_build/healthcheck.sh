#!/bin/bash

[[ $(/fiona/CMS-Fiona-7.0.1/instance/default/bin/rc.npsd status)  == "CM is running" ]] || exit 1
