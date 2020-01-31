#!/bin/bash
status=0
while [[ ${status} != 1 ]]; do
  ruby bin/run.rb
  status=$?
done
