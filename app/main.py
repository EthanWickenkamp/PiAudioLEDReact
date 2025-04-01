import subprocess
import time

def get_connected_devices():
    try:
        output = subprocess.check_output(["bluetoothctl", "devices", "Connected"], text=True)
        return output.strip().splitlines()
    except subprocess.CalledProcessError:
        return []

print("🎧 Watching for Bluetooth audio devices...")

while True:
    devices = get_connected_devices()
    if devices:
        print("🔗 Connected:", devices)
    else:
        print("❌ No devices connected")

    time.sleep(5)