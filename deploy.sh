export DEBIAN_FRONTEND=noninteractive

# Install build dependencies
echo "deb http://ftp.de.debian.org/debian sid main" >> /etc/apt/sources.list
apt update -y
apt install git curl gcc make nginx -y
printf "\n" | apt install gcc-10 -y

# Install MeiliSearch v0.10.0
wget --directory-prefix=/etc/meilisearch/ https://github.com/meilisearch/MeiliSearch/releases/download/v0.10.0/meilisearch.deb
apt install /etc/meilisearch/meilisearch.deb