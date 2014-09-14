echo -e "\nSetup Apache2 and PHP configuration files..."

cp /srv/config/100-site /etc/apache2/sites-available/100-site
chmod 644 /etc/apache2/sites-available/100-site

a2enmod rewrite
a2enmod headers
a2ensite 100-site
a2dissite default
service apache2 reload
