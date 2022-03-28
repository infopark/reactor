#!/bin/sh
cp /tmp/test_db_dump.sql /fiona/test_db_dump.sql
mysql reactor_test -h db < /fiona/test_db_dump.sql
/fiona/CMS-Fiona-7.0.2/instance/default/bin/rc.npsd start
tail -f /dev/null
