import os
import socket
import numpy as np
import sounddevice as sd

# Environment setup for PulseAudio inside container
os.environ["PULSE_SERVER"] = "unix:/run/user/1000/pulse/native"
os.environ["XDG_RUNTIME_DIR"] = "/run/user/1000"
os.environ["PULSE_RUNTIME_PATH"] = "/tmp/pulse"

# WLED setup
WLED_HOSTNAME = "wled3.local"
WLED_IP = "192.168.50.147"     # 🔁 Replace with actual IP
WLED_PORT = 21324
LED_COUNT = 450              # Total LED count
RGB_COLOR = [0, 0, 255]      # Base color (blue)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

def send_wled(rgb: list):
    """Send raw RGB data to WLED via UDP."""
    packet = bytes([val for _ in range(LED_COUNT) for val in rgb])
    sock.sendto(packet, (WLED_IP, WLED_PORT))

def audio_callback(indata, frames, time, status):
    volume = np.linalg.norm(indata) * 10
    brightness = int(np.clip(volume * 8, 0, 255))

    # Apply brightness to base RGB color
    r, g, b = [int(c * (brightness / 255)) for c in RGB_COLOR]
    send_wled([r, g, b])

def main():
    print("🎧 Starting audio reactive mode...")
    try:
        with sd.InputStream(
            channels=1,
            samplerate=44100,
            callback=audio_callback,
            blocksize=1024,
        ):
            while True:
                pass
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
