#!/bin/bash

function ask_ssl_configure {
    while true; do
        read -p "Do you wish to setup ssl with certbot [y/n]? " yn
        case $yn in
            [Yy]* ) echo "ok cool we'll setup ssl with certbot"; break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

function set_domain_name_in_nginx {
    cat << EOF > /etc/nginx/sites-enabled/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name $domainname;

    location / {
        proxy_pass  http://127.0.0.1:7700;
    }
}
EOF
    systemctl restart nginx
}

function ask_domain_name {
    while true; do
        read -p "What is your domain name? " domainname
        case $domainname in
            "" ) echo "Please enter a valid domain name";;
            * ) set_domain_name_in_nginx; ask_ssl_configure; break;;
        esac
    done
}

function ask_domain_name_setup {
    while true; do
        read -p "Do you wish to setup a domain name [y/n]? " yn
        case $yn in
            [Yy]* ) ask_domain_name; break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

function set_master_key {
    while true; do
        read -p "Do you wish to specify you MEILI_API_KEY (otherwise it will be generated) [y/n]? " yn
        case $yn in
            [Yy]* ) read -sp "MEILI_API_KEY: " api_key; break;;
            [Nn]* ) api_key=$(date +%s | sha256sum | base64 | head -c 32); echo "You MEILI_API_KEY is $api_key"; echo "You should keep it somewhere safe."; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    cat << EOF >/etc/systemd/system/meilisearch.service
[Unit]
Description=MeiliSearch
After=systend-user-sessions.service

[Service]
Type=simple
ExecStart=/usr/bin/meilisearch
Environment="MEILI_API_KEY=$api_key"

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl restart meilisearch
}

function ask_master_key_setup {
    while true; do
        read -p "Do you wish to setup a MEILI_API_KEY for your search engine [y/n]? " yn
        case $yn in
            [Yy]* ) set_master_key; break;;
            [Nn]* ) return;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo "Thank you for using MeiliSearch."
echo "This is the first login on this newly confgured VM and we need some basic configuration first."
ask_domain_name_setup
ask_master_key_setup
echo "done"
cp -f /etc/skel/.bashrc /root/.bashrc
