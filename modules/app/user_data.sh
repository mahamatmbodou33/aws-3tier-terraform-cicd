#!/bin/bash
set -euxo pipefail

dnf update -y || yum update -y
dnf install -y httpd awscli unzip || yum install -y httpd aws-cli unzip

systemctl enable httpd
systemctl start httpd

mkdir -p /var/www/html
cd /var/www/html
rm -rf ./*

aws s3 cp "s3://${artifact_bucket}/${artifact_key}" /tmp/${app_name}.zip
unzip -o /tmp/${app_name}.zip -d /var/www/html/

cat > /var/www/html/health.html <<EOF
<html>
  <body>
    <h1>${app_name} healthy</h1>
  </body>
</html>
EOF

chown -R apache:apache /var/www/html || true
chmod -R 755 /var/www/html || true

${user_data_extra}

systemctl restart httpd