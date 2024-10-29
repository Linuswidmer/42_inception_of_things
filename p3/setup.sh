#!/bin/bash

sudo apt-get update && sudo apt-get upgrade && apt-get install -y curl

curl -sfL https://get.docker.com/ | sh -

sudo apt-get update && sudo apt-get install -y kubectl
