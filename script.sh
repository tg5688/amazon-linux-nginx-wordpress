#! /bin/bash

##########
# Build Wordpress with nginx server on Amazon Linux 2
# Configuration includes improved web server performance and security.
##########

DOMAIN_NAME=amiwordpress.com #<-here, type a your domain name
VHOST_USER=amiwordpress  #<- enter the username, you will use to manage the wordpress files on system
VHOST_PASS=amiwordpress_pass

# Wordpress database configuration
WP_DB_NAME=amiwordpress
WP_DB_USER=wordpress 
WP_DB_PASS=wordpress_pass 

# Install nginx, php and mariadb
yum update -y
amazon-linux-extras install -y nginx1
amazon-linux-extras install -y php7.2
yum install -y mariadb-server mariadb

# Create nginx main configuration
cat << EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;

pid /run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    error_log  /var/log/nginx/error.log error;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    # SSL
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # no sslv3 (poodle etc.)
    ssl_prefer_server_ciphers on;

    # Gzip Settings
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_min_length 512;
    gzip_types text/plain application/x-javascript text/javascript application/javascript text/xml text/css application/font-sfnt;

    fastcgi_cache_path /usr/share/nginx/cache/fcgi levels=1:2 keys_zone=microcache:10m max_size=1024m inactive=1h;
    include /etc/nginx/conf.d/*.conf;
}
EOF

# Create cache directory
mkdir -p /usr/share/nginx/cache/fcgi

# PHP-FPM configuration
cat << EOF > /etc/php-fpm.conf
[global]
pid = /run/php-fpm/php7.2-fpm.pid
error_log = /var/log/php-fpm/php-fpm.log
include=/etc/php-fpm.d/*.conf
EOF

# Create default pool
cat << EOF > /etc/php-fpm.d/www.conf
[default]
security.limit_extensions = .php
listen = /var/run/php-fpm/php-fpm.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
user = nginx
group = nginx
pm = dynamic
pm.max_children = 75
pm.start_servers = 8
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500
EOF

# PHP configuration
cat << EOF > /etc/php.ini
[PHP]
engine = On
short_open_tag = Off
asp_tags = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = 17
disable_functions =
disable_classes =
zend.enable_gc = On
expose_php = Off
max_execution_time = 30
max_input_time = 60
memory_limit = 128M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
log_errors_max_len = 1024
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
track_errors = Off
html_errors = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
post_max_size = 8M
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
cgi.fix_pathinfo=0
file_uploads = On
upload_max_filesize = 25M
max_file_uploads = 20
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
[CLI Server]
cli_server.color = On
[Date]
[filter]
[iconv]
[intl]
[sqlite]
[sqlite3]
[Pcre]
[Pdo]
[Pdo_mysql]
pdo_mysql.cache_size = 2000
pdo_mysql.default_socket=
[Phar]
[mail function]
SMTP = localhost
smtp_port = 25
mail.add_x_header = On
[SQL]
sql.safe_mode = Off
[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1
[Interbase]
ibase.allow_persistent = 1
ibase.max_persistent = -1
ibase.max_links = -1
ibase.timestampformat = "%Y-%m-%d %H:%M:%S"
ibase.dateformat = "%Y-%m-%d"
ibase.timeformat = "%H:%M:%S"
[MySQL]
mysql.allow_local_infile = On
mysql.allow_persistent = On
mysql.cache_size = 2000
mysql.max_persistent = -1
mysql.max_links = -1
mysql.default_port =
mysql.default_socket =
mysql.default_host =
mysql.default_user =
mysql.default_password =
mysql.connect_timeout = 60
mysql.trace_mode = Off
[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.cache_size = 2000
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off
[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off
[OCI8]
[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0
[Sybase-CT]
sybct.allow_persistent = On
sybct.max_persistent = -1
sybct.max_links = -1
sybct.min_server_severity = 10
sybct.min_client_severity = 10
[bcmath]
bcmath.scale = 0
[browscap]
[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly =
session.serialize_handler = php
session.gc_probability = 1
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.hash_function = 0
session.hash_bits_per_character = 5
url_rewriter.tags = "a=href,area=href,frame=src,input=src,form=fakeentry"
[MSSQL]
mssql.allow_persistent = On
mssql.max_persistent = -1
mssql.max_links = -1
mssql.min_error_severity = 10
mssql.min_message_severity = 10
mssql.compatibility_mode = Off
mssql.secure_connection = Off
[Assertion]
[COM]
[mbstring]
[gd]
[exif]
[Tidy]
tidy.clean_output = Off
[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5
[sysvshm]
[ldap]
ldap.max_links = -1
[dba]
[opcache]
[curl]
[openssl]
EOF

# User configuration - will be use to manage the wordpress files on system
useradd -p $VHOST_PASS $VHOST_USER
mkdir /home/$VHOST_USER/public_html
mkdir /home/$VHOST_USER/logs

# vhost configuration
cat << EOF > /etc/nginx/conf.d/$VHOST_USER.conf
server {
    listen       80;
    server_name  www.$DOMAIN_NAME;

    client_max_body_size 20m;

    index index.php index.html index.htm;
    root   /home/$VHOST_USER/public_html;

    location / {
        try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
    }

    location ~ \.php$ {
            try_files \$uri =404;
            fastcgi_index index.php;
            set \$no_cache "";

            if (\$request_method = POST) {
              set \$no_cache 1;
            }

            if (\$request_uri ~* "/(wp-admin/|wp-login.php)") {
              set \$no_cache 1;
            }

            if (\$request_uri ~* "/store.*|/cart.*|/my-account.*|/checkout.*|/addons.*") {
              set \$no_cache 1;
            }

            if (\$http_cookie ~* "wordpress_logged_in_") {
              set \$no_cache 1;
            }

            # Cache 
            fastcgi_no_cache \$no_cache;
            fastcgi_cache_bypass \$no_cache;
            fastcgi_cache microcache;
            fastcgi_cache_key \$scheme\$request_method\$server_name\$request_uri\$args;
            fastcgi_cache_valid 200 60m;
            fastcgi_cache_valid 404 1m;
            fastcgi_cache_use_stale updating;

            # FastCGI handling
            fastcgi_pass unix:/var/run/php-fpm/$VHOST_USER.sock;
            fastcgi_pass_header Set-Cookie;
            fastcgi_pass_header Cookie;
            fastcgi_ignore_headers Cache-Control Expires Set-Cookie;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            fastcgi_intercept_errors on;
            include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|ttf|svg|otf)$ {
            expires 30d;
            add_header Pragma public;
            add_header Cache-Control "public";
            access_log off;
    }

}

server {
    listen       80;
    server_name  $DOMAIN_NAME;
    rewrite ^/(.*)$ http://www.$DOMAIN_NAME/$1 permanent;
}
EOF

# PHP-FPM pool configuration
cat << EOF > /etc/php-fpm.d/$VHOST_USER.conf
[$VHOST_USER]
listen = /var/run/php-fpm/$VHOST_USER.sock
listen.owner = $VHOST_USER
listen.group = nginx
listen.mode = 0660
user = $VHOST_USER
group = nginx
pm = dynamic
pm.max_children = 75
pm.start_servers = 8
pm.min_spare_servers = 5
pm.max_spare_servers = 20
pm.max_requests = 500
php_admin_value[upload_max_filesize] = 25M
php_admin_value[error_log] = /home/$VHOST_USER/logs/phpfpm_error.log
php_admin_value[open_basedir] = /home/$VHOST_USER:/tmp
EOF

# Remove default stuff
rm -f /etc/nginx/conf.d/php-fpm.conf
rm -f /etc/nginx/default.d/php.conf


# Maria DB configuration
systemctl start mariadb.service

PASS_SQL_ROOT=$(echo -n @ && cat /dev/urandom | env LC_CTYPE=C tr -dc [:alnum:] | head -c 15)

echo $PASS_SQL_ROOT # Show pass

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$(echo $PASS_SQL_ROOT)') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

CREATE DATABASE $WP_DB_NAME;
CREATE USER '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';
GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO $WP_DB_USER@localhost;     
FLUSH PRIVILEGES;
EOF

# Download Wordpress
cd /home/$VHOST_USER/public_html
wget https://wordpress.org/latest.tar.gz
tar zxf latest.tar.gz
rm latest.tar.gz
mv wordpress/* .
rmdir wordpress/

# Set proper Wordpress file permissions
cd /home/$VHOST_USER/public_html
chown -R $VHOST_USER:nginx .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;  
cd /home
chmod 755 $VHOST_USER

# Restart nginx, php-fpm and mariadb services
systemctl restart nginx.service
systemctl restart php-fpm.service
systemctl restart mariadb.service

# Tell systemd to start services automatically at boot
systemctl enable nginx.service
systemctl enable php-fpm.service
systemctl enable mariadb.service
