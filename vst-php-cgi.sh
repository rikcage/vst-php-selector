#!/bin/bash

# check root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 0
fi

# check OS
if [[ `cat /etc/os-release | grep ^ID=` == "ID=debian" ]]; then
    apt install -y apt-transport-https lsb-release ca-certificates wget
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    apt update
elif [[ `cat /etc/os-release | grep ^ID=` == "ID=ubuntu" ]]; then
    apt update
    add-apt-repository ppa:ondrej/php
else    
    echo "This script must be run on Ubuntu or Debian"
    exit 0
fi

a2enmod cgi

echo "You can enter multiple versions through 'space'."
echo "Enter php version/versions(for example 5.6 7.0 7.1 7.2 7.3 7.4 8.0):"
read -p ">" vers

site_link="https://raw.githubusercontent.com/rikcage/vst-php-selector/main/cgi"

for ver in $vers; do

    apt install -y php$ver php$ver-fpm php$ver-cgi

    wget $site_link/phpcgi-$ver.stpl -O /usr/local/vesta/data/templates/web/apache2/phpcgi-$ver.stpl
    wget $site_link/phpcgi-$ver.tpl -O /usr/local/vesta/data/templates/web/apache2/phpcgi-$ver.tpl
    wget $site_link/phpcgi-$ver.sh -O /usr/local/vesta/data/templates/web/apache2/phpcgi-$ver.sh
    chmod a+x /usr/local/vesta/data/templates/web/apache2/phpcgi-$ver.sh

done

systemctl restart apache2
