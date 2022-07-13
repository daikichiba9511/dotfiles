#!/bin/bash
docker build -t test-dotfiles .
docker run --rm test-dotfiles
docker rmi test-dotfiles
