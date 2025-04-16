import socket
import numpy as np
import pyaudio


# Configuration
ESP32_IP = '192.168.50.147'  # Replace with your ESP32's IP
UDP_PORT = 21324
CHUNK = 1024
RATE = 44100
CHANNELS = 1
FORMAT = pyaudio.paInt16
FFT_BINS = 16

# Create UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Init PyAudio
p = pyaudio.PyAudio()
stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)

print("🎧 Streaming audio to WLED (press Ctrl+C to stop)")

try:
    while True:
        # Read audio chunk
        data = stream.read(CHUNK, exception_on_overflow=False)
        audio = np.frombuffer(data, dtype=np.int16)

        # Apply Hanning window to reduce FFT noise
        windowed = audio * np.hanning(len(audio))

        # Compute FFT
        fft = np.abs(np.fft.rfft(windowed))[:FFT_BINS]
        
        # Normalize to 0-255
        if np.max(fft) > 0:
            fft_norm = np.interp(fft, (0, np.max(fft)), (0, 255)).astype(np.uint8)
        else:
            fft_norm = np.zeros(FFT_BINS, dtype=np.uint8)

        # Build and send packet
        packet = b'A' + fft_norm.tobytes()
        sock.sendto(packet, (ESP32_IP, UDP_PORT))

except KeyboardInterrupt:
    print("\n🛑 Interrupted. Shutting down...")

finally:
    # Clean up resources
    stream.stop_stream()
    stream.close()
    p.terminate()
    sock.close()
    print("✅ Resources released. Goodbye!")

