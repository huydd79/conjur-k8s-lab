FROM php:apache
LABEL maintainer="Joe Tan <joe.tan@cyberark.com>"
LABEL description="CityApp based on Apache and PHP"
RUN docker-php-ext-install pdo_mysql && echo "<?php phpinfo(); ?>" >> /var/www/html/info.php
COPY index.php /var/www/html/
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/apache2-foreground"]
