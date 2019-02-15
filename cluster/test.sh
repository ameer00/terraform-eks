#!/bin/bash

if ! cat $HOME/.bashrc | grep K-PROMPT &> /dev/null ; then
    cd $HOME
    cat $HOME/terraform-eks/cluster/krompt.txt >> $HOME/.bashrc
    source $HOME/.bashrc
fi