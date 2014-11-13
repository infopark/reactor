#!/bin/bash

REPOSITORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RELEASES="$REPOSITORY/releases"

cd "$RELEASES"
rm *.gem 2> /dev/null

cd "$REPOSITORY"
for DIR in $(echo infopark_reactor) ; do
    if [ -d "$REPOSITORY/$DIR" ] ; then
        echo "Building $DIR"
        cd "$REPOSITORY/$DIR" && gem build *.gemspec && mv "$REPOSITORY/$DIR/"*.gem "$RELEASES"
    fi
done
cd "$REPOSITORY"
