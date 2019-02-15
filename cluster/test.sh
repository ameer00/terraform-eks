#!/bin/bash

if cat $HOME/.bashrc | grep K-PROMPT &> /dev/null ; then
    echo success
else
    echo fail
fi