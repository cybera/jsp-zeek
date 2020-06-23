#!/bin/bash

# Copy template if needed
if [ ! -f "Dockerfile.run" ]; then
    cp Dockerfile.run.template Dockerfile.run
fi

docker build -f Dockerfile.run -t zeek .
