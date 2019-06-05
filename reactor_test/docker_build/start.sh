#!/bin/sh

/fiona/CMS-Fiona-7.0.1/instance/default/bin/rc.npsd start && \
/fiona/CMS-Fiona-7.0.1/instance/default/bin/rc.npsd stop && \
/fiona/CMS-Fiona-7.0.1/instance/default/bin/CM -unrailsify && \
/fiona/CMS-Fiona-7.0.1/instance/default/bin/CM -railsify && \
/fiona/CMS-Fiona-7.0.1/instance/default/bin/rc.npsd start && \
tail -f /fiona/CMS-Fiona-7.0.1/instance/default/log/info.log
