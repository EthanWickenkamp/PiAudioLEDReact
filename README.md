# Raspberry Pi container


1. Install raspberry pi OS lite 64 bit

2. ssh pi@ip-address
if need to reset known host
```bash
ssh-keygen -R ip-address
```

3. Install docker 
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker --version
docker compose version
```
Install docker compose if not installed
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

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
push and then pull newer version later in project directory root
```bash
git pull origin main
```

6. start docker compose build or run in detached -d and exec in
```bash
docker compose up --build -d
docker compose up --build
docker exec -it PiAudio bash
```
7. check container is running and check logs
```bash
docker ps
docker logs
```


# Host machine checks
```bash
ps aux | grep pulseaudio
ps aux | grep bluetoothd
ps aux | grep dbus-daemon
```


## Route
3.5 mm jack -> ALSA -> PulseAudio -> Dbus -> bluez daemon -> A2DP sink -> phones bluetooth

### 3.5mm jack
system device 0
```bash
sudo raspi-config
```
can see and edit in config on host

### ALSA
advanced linux sound architecture

### PulseAudio
Install on host
```bash
apt install pulseaudio
```
Mount socket from container to host
```yml
- /run/user/1000/pulse:/run/user/1000/pulse
```
instead we are using xdg
```yml
environment:
        XDG_RUNTIME_DIR: /tmp/xdg
        PULSE_SERVER: unix:/tmp/xdg/pulse/native
```