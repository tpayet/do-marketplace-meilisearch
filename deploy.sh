# Install build dependencies
apt update -y
apt install git curl gcc make nginx -y

# Download and install Rust toolchain
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# Git clone and build MeiliSearch for release on latest tag
git clone https://github.com/meilisearch/MeiliSearch && cd MeiliSearch
git checkout v0.8.4
cargo build --release

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

# Setup firewalls and Nginx
ufw allow 'Nginx Full'
ufw allow 'OpenSSH'
ufw --force enable

# Set Nginx to proxy MeiliSearch
cat << EOF > /etc/nginx/sites-enabled/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass  http://127.0.0.1:7700;
    }
}
EOF
systemctl restart nginx

# Clean up image using DO script
curl https://raw.githubusercontent.com/digitalocean/marketplace-partners/master/scripts/cleanup.sh | bash
rm /var/log/auth.log
rm /var/log/kern.log
rm /var/log/ufw.log
curl https://raw.githubusercontent.com/digitalocean/marketplace-partners/master/scripts/img_check.sh | bash
