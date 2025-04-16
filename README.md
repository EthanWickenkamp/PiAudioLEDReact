# Raspberry Pi Bluetooth and LED Sound Reactive container

## Raspberry Pi setup
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
docker compose up --build
docker compose up --build -d
docker exec -it PiAudio bash
```
7. check container is running and check logs
```bash
docker ps
docker logs
```

## Host machine checks
```bash
ps aux | grep pulseaudio
ps aux | grep bluetoothd
ps aux | grep dbus-daemon
```
We are looking for pulseaudio on a specific socket
We are looking for output audio device and card?
Checking permissions and users


## Route
3.5 mm jack <- ALSA <- PulseAudio <- Dbus <- bluez daemon <- A2DP sink <- phones bluetooth

### 3.5mm jack
system device 0
```bash
sudo raspi-config
```
can see and edit in config on host
### ALSA
advanced linux sound architecture
asound.conf tells to use pulse audio?

### PulseAudio
Install on host
```bash
apt install pulseaudio
```
Mount socket from container to host
```yml
- /run/user/1000/pulse:/run/user/1000/pulse # <-- host PulseAudio socket
- /home/pi/.config/pulse/cookie:/home/audiouser/.config/pulse/cookie:ro  # <-- cookie auth
```
check your etc/pulse for config details
```yml
environment:
      PULSE_SERVER: unix:/run/user/1000/pulse/native
      user: "1000:1000"  # Match host user so you can access /run/user/1000
```

### Dbus
just mount the socket in compose
```yml
- /run/dbus:/run/dbus
```
### bluez daemon
start this as root before pulse audio
```bash
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2
```
we also mount our config in compose where we set rules for BT connection
```yml
- ./config/bluez-main.conf:/etc/bluetooth/main.conf:ro
```
### A2DP sink
bluetooth module on host
```bash
command to check status here
```

### phone bt
need to pair by 
``` bash
docker compose up -d
docker exec -it PiAudio bash
>>>
bluetoothctl
>>>
yes
```
need to trust device on first connection, bluetooth ctl to interface

## UDP to WLED on esp32

can stream led information over UDP port
or with sound reactive fork stream fft packets

need to test more to be sure 

