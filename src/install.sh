#!/bin/bash

### install package test ###
install_home=`pwd -P`

cd $install_home
test_home=$(dirname "$0")
echo "==> INSTALLING Bedtools ...."
cd third_party/bedtools/
make >& make.log
return_code=$?
if [ $return_code -ne 0 ]; then
	echo "ERROR! Bedtools install FAILED!"
	make clean
	exit 1
fi

cd $install_home
test_home=$(dirname "$0")
echo "==> INSTALLING lastz ...."
cd third_party/lastz/
make >& make.log
return_code=$?
if [ $return_code -ne 0 ]; then
	echo "ERROR! lastz install FAILED!"
	make clean
	exit 1
fi

cd $install_home
test_home=$(dirname "$0")
echo "==> INSTALLING makeBlocks ...."
cd third_party/makeBlocks
make >& make.log
return_code=$?
if [ $return_code -ne 0 ]; then
	echo "ERROR! makeBlocks install FAILED!"
	make clean
	exit 1
fi

cd $install_home
echo "==> Check Perl Modules ...."
perl ./check_modules.pl
