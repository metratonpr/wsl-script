#!/bin/bash

echo "========================================"
echo "  🚀 Ambiente de Desenvolvimento WSL"
echo "========================================"

# Atualizar pacotes
sudo apt update && sudo apt upgrade -y
sudo apt install -y software-properties-common curl wget git unzip build-essential apt-transport-https gnupg2 lsb-release ca-certificates

# ================================
# PHP e Laravel
# ================================
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install -y php8.2 php8.2-cli php8.2-common php8.2-mbstring php8.2-xml php8.2-mysql php8.2-curl php8.2-zip php8.2-bcmath php8.2-gd php8.2-sqlite3 php8.2-imap php8.2-readline php8.2-intl php8.2-soap

cd ~
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
composer global require laravel/installer

# ================================
# Python, IA, Ciencia de Dados e Visao Computacional
# ================================
sudo apt install -y python3 python3-pip python3-venv gdal-bin libgdal-dev
pip install --upgrade pip
pip install pandas numpy scipy matplotlib seaborn scikit-learn jupyterlab fastapi uvicorn tensorflow keras torch torchvision plotly dash statsmodels geopandas shapely fiona rasterio pyproj folium contextily cartopy scikit-image transformers datasets sentencepiece langchain llama-index openai chromadb faiss-cpu selenium playwright dvc mlflow opencv-python opencv-contrib-python pillow imageio ultralytics mediapipe 'git+https://github.com/facebookresearch/detectron2.git'

playwright install

# ================================
# Node.js, Frontend, Mobile
# ================================
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g yarn pnpm pm2

# ================================
# Java e Mobile C#
# ================================
sudo apt install -y openjdk-21-jdk maven wget unzip

wget https://services.gradle.org/distributions/gradle-8.7-bin.zip -P /tmp
sudo unzip -d /opt/gradle /tmp/gradle-8.7-bin.zip
sudo ln -s /opt/gradle/gradle-8.7/bin/gradle /usr/bin/gradle

wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0

# ================================
# Rust
# ================================
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

# ================================
# Ruby e Rails
# ================================
sudo apt install -y gnupg2

gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
                                              7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
rvm install 3.3.0
rvm use 3.3.0 --default

gem install rails -v 7.1.3

# ================================
# Banco de Dados
# ================================
sudo apt install -y mysql-server postgresql postgresql-contrib redis-server

wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt update
sudo apt install -y mongodb-org

wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo apt-key add -
echo 'deb https://debian.neo4j.com stable 5' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt update
sudo apt install -y neo4j

wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo apt-key add -
echo "deb https://packagecloud.io/timescaledb/timescaledb/ubuntu/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list
sudo apt update
sudo apt install -y timescaledb-postgresql-14
sudo timescaledb-tune --yes

# ================================
# Elastic Stack
# ================================
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install -y elasticsearch kibana logstash

# ================================
# RabbitMQ
# ================================
sudo apt install -y rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management

# ================================
# Kafka via Docker
# ================================
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER

docker network create kafka-net

docker run -d --name zookeeper --network kafka-net -e ZOOKEEPER_CLIENT_PORT=2181 confluentinc/cp-zookeeper

docker run -d --name kafka --network kafka-net -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
-e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
-p 9092:9092 confluentinc/cp-kafka

# ================================
# Servidores Web (Nginx, Apache, Caddy, Nginx Proxy Manager)
# ================================
sudo apt install -y nginx apache2 supervisor

wget https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64
sudo mv MailHog_linux_amd64 /usr/local/bin/mailhog
sudo chmod +x /usr/local/bin/mailhog

# Caddy Server
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/trusted.gpg.d/caddy-stable.asc
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

# Nginx Proxy Manager via Docker
mkdir -p ~/nginx-proxy-manager && cd ~/nginx-proxy-manager
cat <<EOL > docker-compose.yml
version: '3'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '81:81'
      - '80:80'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOL

docker-compose up -d
cd ~

# ================================
# Grafana
# ================================
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# ================================
# Terminal aprimorado (opcional)
# ================================
sudo apt install -y zsh tmux
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sS https://starship.rs/install.sh | sh -s -- -y
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# ================================
# Finalizacao
# ================================
echo "========================================"
echo " 👌 Ambiente configurado com sucesso!"
echo " ➕ Reinicie o WSL ou execute: source ~/.bashrc"
echo " 🚀 Bancos rodando: MySQL, PostgreSQL, MongoDB, Redis, Neo4j, TimescaleDB"
echo " 🌍 Servicos: Elasticsearch, Kibana, Logstash, RabbitMQ, Kafka, Nginx, Apache, Caddy, Nginx Proxy Manager, Mailhog, Grafana"
echo " 🔧 Linguagens: PHP, Python, Node, Java, .NET, Rust, Ruby"
echo " 🎯 IA e Visao Computacional: TensorFlow, Keras, PyTorch, Transformers, YOLOv8, OpenCV, Detectron2, Mediapipe"
echo " ========================================"
