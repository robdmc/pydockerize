#! /usr/bin/env bash

if [ "$1" = "-h" ]; 
    then
        echo Run with -p option to enable service ports
        exit 0
fi


if [ "$1" = "-p" ]; 
    then
        echo Running with service ports
        docker-compose run --rm --service-ports {service}
    else
        docker-compose run --rm  {service}
fi
