# Raspberry Pi Bluetooth Audio Reactor

A containerized setup for Raspberry Pi that receives Bluetooth audio, outputs it via a connected DAC HAT (or default audio output), and sends real-time audio-reactive data to WLED ESP32 devices over the network.

---

## 🧰 Raspberry Pi Setup

These steps guide you through setting up a fresh Raspberry Pi OS installation for this project.

### 1. Prepare Raspberry Pi OS
- Install **Raspberry Pi OS Lite (64-bit)** using the Raspberry Pi Imager.
- Enable SSH and configure Wi-Fi (if needed) via the Imager's advanced options before writing the SD card.
- Boot the Raspberry Pi and ensure it's connected to your network.

### 2. Initial Connection & Update
- Find your Pi's IP address (e.g., via your router's admin page or a network scanner).
- Connect via SSH (replace `<pi-ip-address>`):
  ```bash
  ssh pi@<pi-ip-address>

If you've connected before, you might need `ssh-keygen -R <pi-ip-address>`

Update the system:

`sudo apt-get update && sudo apt-get upgrade -y`

### 3. Configure Audio Output (DAC HAT Recommended)


This project works best with a dedicated DAC

Identify your **DAC HAT Overlay**, 

Examples: hifiberry-dac, iqaudiodac, allo-boss-dac-pcm512x-audio

Edit Boot Configuration:

`sudo nano /boot/firmware/config.txt`
Or use /boot/config.txt on older OS versions

Add the following lines at the end of the file:

```bash
# Disable built-in audio
dtparam=audio=off
# Enable DAC HAT (replace with your actual overlay name)
dtoverlay=<your-dac-overlay-name>
```

Save and Exit (Ctrl+X, then Y, then Enter).

Reboot for changes to take effect:

`sudo reboot`

Wait for the Pi to restart, then SSH back in.

### 4. Install Docker & Docker Compose
Download and run the official Docker install script:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Add ***pi*** user to the docker group to run Docker commands without sudo:

`sudo usermod -aG docker pi`

`sudo reboot`

Verify installation:

```bash
docker --version
docker compose version
```

If docker compose version fails, you might need
 `sudo apt-get install -y docker-compose-plugin`

### 5. Clone Project Repository
Clone the project code (replace with your actual repository URL):

`git clone https://github.com/USERNAME/REPONAME.git`

`cd PiAudioLEDReact`

To update later: `git pull origin main`

## ✅ Host System Checks & Verification
Before running the application verify the host system's audio device, and Pulse audio and Bluetooth server/socket.

### 1. Verify Audio Device (ALSA)
List ALSA playback devices. You should see your DAC HAT listed and not the default bcm2835 device (if disabled via dtparam=audio=off).

`aplay -l`

### 2. Verify PulseAudio
Check if PulseAudio is running for the pi user (it should start automatically on modern Raspberry Pi OS Desktop, but maybe not Lite):

`systemctl --user status pulseaudio.service pulseaudio.socket`

If the service is not found or inactive: Install PulseAudio and enable/start the user service:

```bash
# Install PulseAudio packages
sudo apt-get install -y pulseaudio pulseaudio-utils
# Enable and start the service for the current user pi
systemctl --user enable --now pulseaudio.service pulseaudio.socket
# Re-check status after installing
systemctl --user status pulseaudio.service pulseaudio.socket
```

Once PulseAudio is running:

List PulseAudio output sinks. Your DAC HAT should be listed, often as card 0. Note its name or index (e.g., alsa_output.platform-soc_sound_xyz.analog-stereo).

`pactl list sinks short`

Check the default sink:

`pactl info | grep "Default Sink"`

If the DAC is not the default, set it:

`pactl set-default-sink <dac_sink_name_or_index>`

### 3. Verify Bluetooth
Check the Bluetooth service status:

`systemctl status bluetooth`

Show Bluetooth controller info:

`bluetoothctl show`

If Bluetooth isn't working, try: `sudo apt install -y bluez bluez-tools pulseaudio-module-bluetooth` then `sudo systemctl enable --now bluetooth`

### 4. Verify D-Bus
Check if the system D-Bus daemon is running (required for Bluetooth):

`ps aux | grep 'dbus-daemon --system'`

## 🚀 Running the Application
Now you can build and start the Docker container.

### 1. Build and Run:

```bash
# Navigate to the project directory if you aren't already there
cd ~/PiAudioLEDReact

# Build the image and start the container(s) in detached mode
docker compose up --build -d
#simple for if working
docker compose up
docker compose down
```

### 2. Check Container Status:

`docker ps`

Look for a container named PiAudio (or similar) with status "Up"

View Logs:

`docker logs PiAudio`
Use `docker logs -f PiAudio` to follow logs in real-time

### 3. Access Container Shell (for debugging):

`docker exec -it PiAudio bash`


### 4. To automatically start on boot
create a `systemd` service file to run `docker compose up -d`

## 🔊 Audio Routing Overview
The audio flows through several components:

**Bluetooth Device → Pi Bluetooth → BlueZ Daemon → D-Bus → Host PulseAudio → ALSA → DAC HAT** (or other default output)

(Proccessing) -> Container (soundreact.py) → Network → WLED ESP32

**Bluetooth (A2DP Sink):** Managed by BlueZ and integrated with PulseAudio via pulseaudio-module-bluetooth. The container starts bluetoothctl to make the Pi discoverable/pairable.

**BlueZ & D-Bus:** The Bluetooth stack communicates system-wide via D-Bus. The container accesses the host's D-Bus socket (/run/dbus).

**PulseAudio (Host):** Crucially, the container uses the host's PulseAudio service, connecting via the mounted socket (/run/user/1000/pulse) and authentication cookie. Audio from Bluetooth appears as a source in the host's PulseAudio. Playback from the container (if any) and the primary Bluetooth output goes to the host's default PulseAudio sink (which should be your DAC HAT if configured).

**ALSA:** The low-level sound system used by PulseAudio to talk to the hardware (DAC HAT).

**soundreact.py:** Captures audio from the host's PulseAudio (likely a monitor of the Bluetooth source), processes it (FFT analysis), and streams LED/audio data.

## 🌈 Sending Audio-Reactive LED Data to WLED
The Python script (soundreact.py - check filename in /app) sends data to your WLED device(s).

WLED Setup:

Ensure your WLED device is connected to the same network as the Pi.

Set WLED to receive real-time UDP data: Go to WLED UI -> Config -> Sync Interfaces -> Network UDP -> Set "Receive UDP Realtime" to enabled (usually port 21324).

Configuration in Script:

You may need to edit the Python script (app/soundreact.py) to set:

WLED_IP: The IP address or hostname of your WLED device (e.g., "192.168.1.100" or "wled.local"). Use <your-wled-ip-or-hostname> as placeholder if needed.

WLED_PORT: Default is 21324.

LED_COUNT: Ensure this matches the number of LEDs configured in WLED for accurate effects.

Data Format: The script typically sends UDP packets in WLED's Realtime Protocol format (e.g., DRGB - Direct RGB).

## ✅ Summary
Installs OS, configures DAC HAT (recommended), installs Docker.

Verifies host audio (ALSA/PulseAudio) and Bluetooth setup.

Runs a Docker container using host's PulseAudio/D-Bus/Network.

Container receives Bluetooth audio via host services.

Audio outputs through the host's default PulseAudio sink (ideally the DAC HAT).

Container Python script processes audio and streams LED data via UDP to WLED.

## 🧪 Troubleshooting / Debugging
Check Container Logs: docker logs PiAudio is your first step.

Exec into Container: docker exec -it PiAudio bash

Inside Container:

Check PulseAudio connection: pactl info (should show host server details).

List PulseAudio sources: pactl list sources short (look for Bluetooth source when connected).

Test audio capture: python3 -m sounddevice (lists devices accessible via PortAudio/PulseAudio).

Manually run the script: python3 /app/soundreact.py to see direct output/errors.

Check Bluetooth status: bluetoothctl devices paired, bluetoothctl devices connected.

Check Host: Re-verify steps in "Host System Checks", especially PulseAudio default sink (pactl info).

WLED: Ensure WLED device is online, accessible from Pi (ping <your-wled-ip-or-hostname>), and UDP Realtime is enabled