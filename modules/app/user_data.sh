#!/bin/bash
set -euxo pipefail

if command -v dnf >/dev/null 2>&1; then
  dnf update -y
  dnf install -y httpd awscli unzip
else
  yum update -y
  yum install -y httpd aws-cli unzip
fi

systemctl enable httpd
systemctl start httpd

mkdir -p /var/www/html
rm -rf /var/www/html/*

cat > /var/www/html/health.html <<EOF
<html>
  <head><title>${app_name} health</title></head>
  <body>
    <h1>${app_name} is healthy</h1>
  </body>
</html>
EOF

cat > /var/www/html/index.html <<EOF
<html>
  <body>
    <h1>${app_name} bootstrap success</h1>
  </body>
</html>
EOF

aws s3 cp "s3://${artifact_bucket}/${artifact_key}" "/tmp/${app_name}.zip" || true

if [ -f "/tmp/${app_name}.zip" ]; then
  unzip -o "/tmp/${app_name}.zip" -d /var/www/html/
fi

chown -R apache:apache /var/www/html || true
chmod -R 755 /var/www/html || true

if command -v restorecon >/dev/null 2>&1; then
  restorecon -R /var/www/html || true
fi

systemctl restart httpd