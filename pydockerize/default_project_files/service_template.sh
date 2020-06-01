#! /usr/bin/env bash

# Change into the same directory as this script
DIR="$( cd "$( dirname "${{BASH_SOURCE[0]}}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"


# Print help if requested
if [ "$1" = "-h" ]; 
    then
        echo Run with -p option to enable service ports
        exit 0
fi


# Run with service ports if requested
if [ "$1" = "-p" ]; 
    then
        echo Running with service ports
        docker-compose run --rm --service-ports {service}
    else
        docker-compose run --rm  {service}
fi
