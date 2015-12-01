#!/bin/sh

TAG_NAME=${TAG_NAME:-"local"}

set -e

docker build -t lune/dev-drupal:${TAG_NAME} .
