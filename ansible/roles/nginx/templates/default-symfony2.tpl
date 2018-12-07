server {
    listen 80;

    client_max_body_size 2M;

    root /vagrant/web;
    index app.php app_dev.php;

    server_name {{ servername }};

    location / {
        if (-f $document_root/.enabled_maintenance_mode) {
            return 503;
        }
        # try to serve file directly, fallback to app_dev.php
        try_files $uri /app_dev.php$is_args$args;
    }

    error_page 503 @maintenance;
    location @maintenance {
        rewrite ^(.*)$ /maintenance_index.html break;
    }

    # DEV
    # This rule should only be placed on your development environment
    # In production, don't include this and don't deploy app_dev.php or config.php
    location ~ ^/(app_dev|app|app_bdd|config)\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;
    }

    # PROD
    location ~ ^/app\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/app.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }

    # return 404 for all other php files not matching the front controller
    location ~ \.php$ {
        return 404;
    }
}
