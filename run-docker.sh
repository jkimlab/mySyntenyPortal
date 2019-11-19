#!/usr/bin/env bash
PORT=9090
docker run -it --rm --entrypoint /bin/bash -p $PORT:80 -v $PWD:/code sweb "$@"
