# Raspberry Pi Bluetooth + WLED Sound Reactive Docker Setup

A self-contained containerized setup to stream audio over Bluetooth to a Raspberry Pi and send real-time LED data to a WLED ESP32 device.

---

## 🧰 Raspberry Pi Setup

### 1. Flash and SSH
- Install **Raspberry Pi OS Lite (64-bit)**.
- Boot and connect to network.
- SSH in:
```bash
ssh pi@<ip-address>
```
To clear known hosts (if needed):
```bash
ssh-keygen -R <ip-address>
```

### 2. Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```
Verify:
```bash
docker --version
docker compose version
```
Install Docker Compose plugin if not available:
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
```

### 3. Add `pi` to Docker group
```bash
sudo usermod -aG docker pi
sudo reboot
```

### 4. Clone Project
```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO
```
To update:
```bash
git pull origin main
```

### 5. Start Docker Compose
```bash
docker compose up --build
# or in detached mode:
docker compose up --build -d
docker exec -it PiAudio bash
```

### 6. Check container status
```bash
docker ps
docker logs PiAudio
```

---

## ✅ Host System Checks

### PulseAudio
```bash
systemctl --user status pulseaudio.service
pactl info
pactl list sinks short
pactl list sources short
```

### Bluetooth Daemon
```bash
systemctl status bluetooth
bluetoothctl show
```

### DBus
```bash
ps aux | grep dbus-daemon
```

### Audio Output Devices
```bash
aplay -l
```

---

## 🔊 Audio Routing Overview

```plaintext
Phone (Bluetooth) → A2DP Sink → BlueZ Daemon → DBus → PulseAudio → ALSA → 3.5mm Jack
```

### 🎧 3.5mm Jack (Output)
```bash
sudo raspi-config
# Configure audio output device
```

### 🎚 ALSA (Advanced Linux Sound Architecture)
`asound.conf` can route audio to PulseAudio.

### 🔁 PulseAudio
Install (if not installed):
```bash
sudo apt install pulseaudio
```
Docker Compose mounts:
```yaml
volumes:
  - /run/user/1000/pulse:/run/user/1000/pulse
  - /home/pi/.config/pulse/cookie:/home/audiouser/.config/pulse/cookie:ro
```
Container environment:
```yaml
environment:
  PULSE_SERVER: unix:/run/user/1000/pulse/native
user: "1000:1000"  # Match UID with host Pulse
```

### 🔄 DBus
Mount host socket:
```yaml
- /run/dbus:/run/dbus
```

### 📡 BlueZ Daemon (Bluetooth)
Start manually (inside container):
```bash
bluetoothd --experimental --debug > /tmp/bluetoothd.log 2>&1 &
sleep 2
```
Mount config file in Compose:
```yaml
- ./config/bluez-main.conf:/etc/bluetooth/main.conf:ro
```

### 🎼 A2DP Sink (Bluetooth Audio)
Ensure Bluetooth modules are loaded:
```bash
pactl list modules short | grep bluetooth
```
Use `bluetoothctl` to pair:
```bash
docker exec -it PiAudio bash
bluetoothctl
# power on
# agent NoInputNoOutput
# default-agent
# discoverable on
# pairable on
# trust <device>
# connect <device>
```

---

## 🌈 Sending Audio-Reactive LED Data to WLED (ESP32)

- WLED ESP32 must be set to **realtime override**
- UDP packets are sent to port `21324`
- Total LED count should match `main.py`

Sample `main.py` sends brightness-adjusted RGB values via UDP:
```python
# RGB data is streamed to WLED using socket.sendto(...)
# LED_COUNT = 450
# socket.sendto(packet, ("wled3.local", 21324))
```

For built-in WLED effects (e.g., VU meter), use HTTP JSON:
```bash
curl -X POST http://wled3.local/json/state -d '{"fx":34}'
```

---

## ✅ Summary
- Audio flows from phone → BT → PulseAudio → Pi 3.5mm
- LED data is computed on the Pi and streamed to WLED
- Fully containerized with Docker Compose
- You can exec into the container to debug audio or LED output anytime

---

## 🧪 TODO / Debug Tips
- Check `pactl list sources short` inside container to confirm BT audio source
- If needed, force device index in Python using `sd.query_devices()`
- Use `python3 -m sounddevice` to test audio in container
- Add visual debugging (e.g., print brightness or FFT bins)
- Print connection and stream status in `main.py`

