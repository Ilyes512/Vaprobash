#!/usr/bin/env bash

# Test if git is installed
git --version > /dev/null 2>&1
GIT_IS_INSTALLED=$?

if [[ $GIT_IS_INSTALLED -gt 0 ]]; then
    echo ">>> ERROR: PHPloy install requires git"
    exit 1
fi

# Test if cURL is installed
curl --version > /dev/null 2>&1
CURL_IS_INSTALLED=$?

if [ $CURL_IS_INSTALLED -gt 0 ]; then
    echo ">>> ERROR: PHPloy install requires cURL"
    exit 1
fi

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

if [ $PHP_IS_INSTALLED -gt 0 ]; then
    echo ">>> ERROR: PHPloy install requires PHP"
    exit 1
fi

echo ">>> Installing git-ftp";

curl --silent -L https://raw.githubusercontent.com/banago/PHPloy/master/phploy > phploy
sudo chmod guo+x phploy
sudo mv phploy /usr/local/bin
