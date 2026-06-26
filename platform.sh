#!/bin/bash

if [ "$1" == "icarus" ]; then 
  cp ./build/icarus/Makefile . ;
  
elif [ "$1" == "synopsys"]; then
  cp ./build/synopsys/Makefile . ; 

else 
  echo "Usage: ./platform.sh <icarus | synopsys> "

fi 

