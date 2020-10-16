server {
    listen 80;

    client_max_body_size 2M;

    root /vagrant/public;
    index index.php;

    server_name {{ servername }};

    location /maintenance.jpg {
        break;
    }

    location / {
        if (-f $document_root/.enabled_maintenance_mode) {
            return 503;
        }

        # try to serve file directly, fallback to index.php
        try_files $uri /index.php$is_args$args;
    }

    error_page 503 @maintenance;
    location @maintenance {
        rewrite ^(.*)$ /maintenance_index.html break;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        fastcgi_buffers 8 8k;
        fastcgi_buffer_size 16k;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT $realpath_root;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/index.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }

    # return 404 for all other php files not matching the front controller
    location ~ \.php$ {
        return 404;
    }
}
