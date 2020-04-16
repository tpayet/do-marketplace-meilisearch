export DEBIAN_FRONTEND=noninteractive

# Install build dependencies
echo "deb http://ftp.de.debian.org/debian sid main" >> /etc/apt/sources.list
apt update -y
apt install git curl gcc make nginx -y
apt install gcc-10 -y

# Install MeiliSearch v0.10.0
wget --directory-prefix=/etc/meilisearch/ https://github.com/meilisearch/MeiliSearch/releases/download/v0.10.0/meilisearch.deb
apt install /etc/meilisearch/meilisearch.deb

# Prepare systemd service for MeiliSearch
mv target/release/meilisearch /usr/bin/
cat << EOF >/etc/systemd/system/meilisearch.service
[Unit]
Description=MeiliSearch
After=systend-user-sessions.service

[Service]
Type=simple
ExecStart=/usr/bin/meilisearch

[Install]
WantedBy=default.target
EOF

# Start MeiliSearch service
systemctl enable meilisearch
systemctl start meilisearch
