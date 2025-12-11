#!/bin/bash
set -euxo pipefail

# ===== Variables passed from Terraform =====
aws_region="${aws_region}"
efs_id="${efs_id}"
lb_dns="${lb_dns}"
db_host="${db_host}"
db_name="${db_name}"
db_user="${db_user}"
db_pass="${db_pass}"
BLOG_DOMAIN="${BLOG_DOMAIN}"

REPO_URL="https://github.com/nancytcheby/Nancys-Blog.git"

# ===== Packages & services =====
dnf -y update
dnf -y install git httpd php php-fpm php-mysqlnd amazon-efs-utils mariadb105
systemctl enable --now php-fpm httpd

# Apache basics
echo 'DirectoryIndex index.php index.html' > /etc/httpd/conf.d/dir.conf
sed -i -E 's/^[[:space:]]*AllowOverride[[:space:]]+None/    AllowOverride All/' /etc/httpd/conf/httpd.conf

# SELinux allowances
setsebool -P httpd_can_network_connect on || true
setsebool -P httpd_use_nfs on || true

# ===== Mount EFS at /var/www/html =====
mkdir -p /var/www/html

FSTAB_LINE="${efs_id}.efs.${aws_region}.amazonaws.com:/  /var/www/html  nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev  0 0"
grep -q "[[:space:]]${efs_id}\.efs\.${aws_region}\.amazonaws\.com:/" /etc/fstab || echo "$FSTAB_LINE" >> /etc/fstab

mount -t nfs4 "${efs_id}.efs.${aws_region}.amazonaws.com:/" /var/www/html

# ===== First boot: populate site into EFS if empty =====
if [ ! -f /var/www/html/wp-config.php ]; then
  rm -rf /var/www/html/*
  git clone --depth 1 -b main "$REPO_URL" /var/www/html || true
  [ -f /var/www/html/wp-config.php ] || \
    { [ -f /var/www/html/wp-config-sample.php ] && cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php; }
fi

# ===== Fix DB_HOST from GitHub repo =====
# GitHub repo has old database endpoint, replace with current one
sed -i "s/wordpressnancy\.c8x2s4kiedw0\.us-east-1\.rds\.amazonaws\.com/${db_host}/" /var/www/html/wp-config.php || true

# ===== HTTPS behind ALB (X-Forwarded-Proto) =====
if ! grep -q "X_FORWARDED_PROTO" /var/www/html/wp-config.php; then
  cat >> /var/www/html/wp-config.php <<'PHP'
/* Handle HTTPS behind a load balancer/proxy */
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
  $_SERVER['HTTPS'] = 'on';
}
PHP
fi

# ===== Fill DB config =====
sed -i "s/database_name_here/${db_name}/"      /var/www/html/wp-config.php || true
sed -i "s/username_here/${db_user}/"           /var/www/html/wp-config.php || true
sed -i "s/password_here/${db_pass}/"           /var/www/html/wp-config.php || true
sed -i "s/localhost/${db_host}/"               /var/www/html/wp-config.php || true

sed -i -E "s/define\('DB_NAME'.*/define('DB_NAME', '${db_name}');/"           /var/www/html/wp-config.php
sed -i -E "s/define\('DB_USER'.*/define('DB_USER', '${db_user}');/"           /var/www/html/wp-config.php
sed -i -E "s/define\('DB_PASSWORD'.*/define('DB_PASSWORD', '${db_pass}');/"   /var/www/html/wp-config.php
sed -i -E "s/define\('DB_HOST'.*/define('DB_HOST', '${db_host}');/"           /var/www/html/wp-config.php

# ===== Set site URL =====
if command -v mysql >/dev/null 2>&1; then
  if host "$BLOG_DOMAIN" >/dev/null 2>&1; then
    mysql -h "${db_host}" -u "${db_user}" -p"${db_pass}" "${db_name}" -e \
      "UPDATE wp_options SET option_value='http://${BLOG_DOMAIN}' WHERE option_name IN ('siteurl','home');"
  else
    mysql -h "${db_host}" -u "${db_user}" -p"${db_pass}" "${db_name}" -e \
      "UPDATE wp_options SET option_value='http://${lb_dns}' WHERE option_name IN ('siteurl','home');"
  fi
fi

# ===== Permissions =====
chown -R apache:apache /var/www/html
find /var/www/html -type d -exec chmod 2775 {} \;
find /var/www/html -type f -exec chmod 0664 {} \;

echo '<?php http_response_code(200); echo "OK"; ?>' > /var/www/html/health.php
chown apache:apache /var/www/html/health.php
chmod 0644 /var/www/html/health.php

systemctl restart php-fpm httpd
echo "[OK] Stack ready."