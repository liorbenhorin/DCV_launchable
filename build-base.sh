#!/bin/bash
# Build the base image (only need to run once or when base packages change)
cd dcv-server
docker build -f Dockerfile.base -t dcv-base:latest .
