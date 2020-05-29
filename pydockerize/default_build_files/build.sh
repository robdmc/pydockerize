#! /usr/bin/env bash
docker rmi {image_name} 2>/dev/null || true
docker build -t {image_name} .
