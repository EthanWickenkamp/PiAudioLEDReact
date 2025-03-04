# Raspberry Pi container


Install raspberry pi OS lite 64 bit

ssh pi@<ip-address>

Install docker 
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

add user to docker group no more sudo for docker cmd
```bash
sudo usermod -aG docker pi
sudo reboot
```

clone the project repo
```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO
```

start docker compose build and run in detached -d
```bash
docker-compose up --build -d
```
check container is running and check logs
```bash
docker ps
docker logs -f bluetooth_audio
```

