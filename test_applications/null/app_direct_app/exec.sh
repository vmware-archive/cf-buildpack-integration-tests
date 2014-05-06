#!/bin/sh
header=`curl $APPDIRECT_URL -i | grep HTTP`

if [ "$header" == "" ]; then
  echo "-----> Not able to connect to AppDirect"
else
  echo "-----> Connected to AppDirect"
fi
