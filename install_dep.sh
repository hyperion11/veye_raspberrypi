#!/usr/bin/env bash

# Install all the dependencies needed to build OpenHD from source.
# TODO do we need libgstreamer1.0-dev and libgstreamer-plugins-base1.0-dev ?
   

apt -y install curl git ruby-dev python3-pip || exit 1

gem install fpm
pip install --upgrade cloudsmith-cli

