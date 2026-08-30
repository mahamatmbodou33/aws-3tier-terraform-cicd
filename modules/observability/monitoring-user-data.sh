#!/bin/bash
set -eux

yum update -y
yum install -y docker awscli

systemctl enable docker
systemctl start docker

mkdir -p /opt/prometheus/rules
mkdir -p /opt/alertmanager

docker network create monitoring || true

cat > /opt/alertmanager/alertmanager.yml <<'EOF'
global:

route:
  receiver: email-alerts
  group_wait: 10s
  group_interval: 1m
  repeat_interval: 1h

receivers:
  - name: email-alerts
    email_configs:
      - to: 'mahamatmbodou33@gmail.com'
        send_resolved: true
EOF

cat > /opt/prometheus/rules/alert-rules.yml <<'EOF'
groups:
  - name: app-availability-alerts
    rules:
      - alert: AppDown
        expr: probe_success == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Application is down: {{ $labels.instance }}"
          description: "{{ $labels.instance }} has been unreachable for more than 1 minute."

  - name: ec2-alerts
    rules:
      - alert: HighCPUUsage
        expr: (100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)) > 80
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for more than 1 minute."

      - alert: InstanceDown
        expr: up{job="ec2-node-exporter"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Instance down: {{ $labels.instance }}"
          description: "Node Exporter target is down."

      - alert: HighDiskUsage
        expr: 100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} * 100) / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High disk usage on {{ $labels.instance }}"
          description: "Root filesystem usage is above 80%."
EOF

cat > /opt/prometheus/prometheus.yml <<EOF
global:
  scrape_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "alertmanager:9093"

rule_files:
  - "/etc/prometheus/rules/alert-rules.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets:
          - "localhost:9090"

  - job_name: "app1-http-check"
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - "https://app1.mbodou.org"
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: "blackbox-exporter:9115"

  - job_name: "app2-http-check"
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - "https://app2.mbodou.org"
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: "blackbox-exporter:9115"

  - job_name: "ec2-node-exporter"
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9100

    relabel_configs:
      - source_labels: [__meta_ec2_tag_Environment]
        regex: ${environment}
        action: keep

      - source_labels: [__meta_ec2_tag_App]
        regex: app1|app2
        action: keep

      - source_labels: [__meta_ec2_tag_App]
        target_label: app

      - source_labels: [__meta_ec2_tag_Name]
        target_label: name

      - source_labels: [__meta_ec2_private_ip]
        target_label: instance
EOF

docker rm -f alertmanager || true
docker rm -f prometheus || true
docker rm -f grafana || true
docker rm -f blackbox-exporter || true

docker run -d \
  --name alertmanager \
  --network monitoring \
  --restart always \
  -p 9093:9093 \
  -v /opt/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
  prom/alertmanager:latest

docker run -d \
  --name blackbox-exporter \
  --network monitoring \
  --restart always \
  -p 9115:9115 \
  prom/blackbox-exporter:latest

docker run -d \
  --name prometheus \
  --network monitoring \
  --restart always \
  -p 9090:9090 \
  -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /opt/prometheus/rules:/etc/prometheus/rules \
  prom/prometheus:latest

docker run -d \
  --name grafana \
  --network monitoring \
  --restart always \
  -p 3000:3000 \
  grafana/grafana:latest

# #!/bin/bash
# set -eux

# yum update -y
# yum install -y docker awscli

# systemctl enable docker
# systemctl start docker

# mkdir -p /opt/prometheus/rules
# mkdir -p /opt/alertmanager

# # Create Docker network for Prometheus, Alertmanager, and Grafana
# docker network create monitoring || true

# # Alertmanager config
# cat > /opt/alertmanager/alertmanager.yml <<'EOF'
# global:
#   resolve_timeout: 5m
#   smtp_smarthost: 'smtp.gmail.com:587'
#   smtp_from: 'mahamatmbodou33@gmail.com'
#   smtp_auth_username: 'mahamatmbodou33@gmail.com'
#   smtp_auth_password: '${gmail_app_password}'
#   smtp_require_tls: true

# route:
#   receiver: email-alerts
#   group_wait: 10s
#   group_interval: 1m
#   repeat_interval: 1h

# receivers:
#   - name: email-alerts
#     email_configs:
#       - to: 'mahamatmbodou33@gmail.com'
#         send_resolved: true
# EOF

# # Prometheus alert rules
# cat > /opt/prometheus/rules/alert-rules.yml <<'EOF'
# groups:
#   - name: ec2-alerts
#     rules:
#       - alert: HighCPUUsage
#         expr: (100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100)) > 80
#         for: 1m
#         labels:
#           severity: warning
#         annotations:
#           summary: "High CPU usage on {{ $labels.instance }}"
#           description: "CPU usage is above 80% for more than 1 minute."

#       - alert: InstanceDown
#         expr: up{job="ec2-node-exporter"} == 0
#         for: 1m
#         labels:
#           severity: critical
#         annotations:
#           summary: "Instance down: {{ $labels.instance }}"
#           description: "Node Exporter target is down."

#       - alert: HighDiskUsage
#         expr: 100 - ((node_filesystem_avail_bytes{mountpoint="/",fstype!="rootfs"} * 100) / node_filesystem_size_bytes{mountpoint="/",fstype!="rootfs"}) > 80
#         for: 2m
#         labels:
#           severity: warning
#         annotations:
#           summary: "High disk usage on {{ $labels.instance }}"
#           description: "Root filesystem usage is above 80%."
# EOF

# # Prometheus config
# cat > /opt/prometheus/prometheus.yml <<EOF
# global:
#   scrape_interval: 15s

# alerting:
#   alertmanagers:
#     - static_configs:
#         - targets:
#             - "alertmanager:9093"

# rule_files:
#   - "/etc/prometheus/rules/alert-rules.yml"

# scrape_configs:
#   - job_name: "prometheus"
#     static_configs:
#       - targets:
#           - "localhost:9090"

#   - job_name: "ec2-node-exporter"
#     ec2_sd_configs:
#       - region: ${aws_region}
#         port: 9100

#     relabel_configs:
#       - source_labels: [__meta_ec2_tag_Environment]
#         regex: ${environment}
#         action: keep

#       - source_labels: [__meta_ec2_tag_App]
#         regex: app1|app2
#         action: keep

#       - source_labels: [__meta_ec2_tag_App]
#         target_label: app

#       - source_labels: [__meta_ec2_tag_Name]
#         target_label: name

#       - source_labels: [__meta_ec2_private_ip]
#         target_label: instance
# EOF

# # Remove old containers if they exist
# docker rm -f alertmanager || true
# docker rm -f prometheus || true
# docker rm -f grafana || true

# # Start Alertmanager
# docker run -d \
#   --name alertmanager \
#   --network monitoring \
#   --restart always \
#   -p 9093:9093 \
#   -v /opt/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
#   prom/alertmanager:latest

# # Start Prometheus
# docker run -d \
#   --name prometheus \
#   --network monitoring \
#   --restart always \
#   -p 9090:9090 \
#   -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
#   -v /opt/prometheus/rules:/etc/prometheus/rules \
#   prom/prometheus:latest

# # Start Grafana
# docker run -d \
#   --name grafana \
#   --network monitoring \
#   --restart always \
#   -p 3000:3000 \
#   grafana/grafana:latest
