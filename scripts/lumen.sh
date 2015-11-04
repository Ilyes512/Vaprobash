#!/usr/bin/env bash

echo ">>> Installing Lumen"

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

# Test if HHVM is installed
hhvm --version > /dev/null 2>&1
HHVM_IS_INSTALLED=$?

[[ $HHVM_IS_INSTALLED -ne 0 && $PHP_IS_INSTALLED -ne 0 ]] && { printf "!!! PHP/HHVM is not installed.\n    Installing Lumen aborted!\n"; exit 0; }

# Test if Composer is installed
composer -v > /dev/null 2>&1 || { printf "!!! Composer is not installed.\n    Installing Lumen aborted!"; exit 0; }

# Test if Server IP is set in Vagrantfile
[[ -z "$1" ]] && { printf "!!! IP address not set. Check the Vagrantfile.\n    Installing Lumen aborted!\n"; exit 0; }

# Check if Lumen root is set. If not set use default
if [[ -z $2 ]]; then
    lumen_root_folder="/vagrant/lumen"
else
    lumen_root_folder="$2"
fi

lumen_public_folder="$lumen_root_folder/public"

# Test if Apache or Nginx is installed
nginx -v > /dev/null 2>&1
NGINX_IS_INSTALLED=$?

apache2 -v > /dev/null 2>&1
APACHE_IS_INSTALLED=$?

# Create Lumen folder if needed
if [[ ! -d $lumen_root_folder ]]; then
    mkdir -p $lumen_root_folder
fi

if [[ ! -f "$lumen_root_folder/composer.json" ]]; then
    if [[ $HHVM_IS_INSTALLED -eq 0 ]]; then
        # Create Lumen
        if [[ "$4" == 'latest-stable' ]]; then
            hhvm -v ResourceLimit.SocketDefaultTimeout=30 -v Http.SlowQueryThreshold=30000 -v Eval.Jit=false /usr/local/bin/composer \
            create-project --prefer-dist laravel/lumen $lumen_root_folder
        else
            hhvm -v ResourceLimit.SocketDefaultTimeout=30 -v Http.SlowQueryThreshold=30000 -v Eval.Jit=false /usr/local/bin/composer \
            create-project laravel/lumen:$4 $lumen_root_folder
        fi
    else
        # Create Lumen
        if [[ "$4" == 'latest-stable' ]]; then
            composer create-project --prefer-dist laravel/lumen $lumen_root_folder
        else
            composer create-project laravel/lumen:$4 $lumen_root_folder
        fi
    fi
else
    # Go to vagrant folder
    cd $lumen_root_folder

    if [[ $HHVM_IS_INSTALLED -eq 0 ]]; then
        hhvm -v ResourceLimit.SocketDefaultTimeout=30 -v Http.SlowQueryThreshold=30000 -v Eval.Jit=false /usr/local/bin/composer \
        install --prefer-dist
    else
        composer install --prefer-dist
    fi

    # Go to the previous folder
    cd -
fi

if [[ $NGINX_IS_INSTALLED -eq 0 ]]; then
    # Change default vhost created
    sudo sed -i "s@root /vagrant@root $lumen_public_folder@" /etc/nginx/sites-available/vagrant
    sudo service nginx reload
fi

if [[ $APACHE_IS_INSTALLED -eq 0 ]]; then
    # Find and replace to find public_folder and replace with lumen_public_folder
    # Change DocumentRoot
    # Change ProxyPassMatch fcgi path
    # Change <Directory ...> path
    sudo sed -i "s@$3@$lumen_public_folder@" /etc/apache2/sites-available/$1.xip.io.conf


    sudo service apache2 reload
fi
