# Raspberry Pi container


1. Install raspberry pi OS lite 64 bit

2. ssh pi@ip-address

3. Install docker 
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker --version
```
Install docker compose 
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
docker compose version
```

4. add user to docker group no more sudo for docker cmd
```bash
sudo usermod -aG docker pi
sudo reboot
```

5. clone the project repo
```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO
```

6. start docker compose build and run in detached -d
```bash
docker-compose up --build -d
```
7. check container is running and check logs
```bash
docker ps
docker logs -f bluetooth_audio
```

