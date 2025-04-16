import socket
import numpy as np
import pyaudio

# Configuration
ESP32_IP = '192.168.50.147'  # Replace with your ESP32's IP address
UDP_PORT = 21324
CHUNK = 1024  # Number of audio samples per frame
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100  # Sampling rate

# Initialize UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Initialize PyAudio
p = pyaudio.PyAudio()
stream = p.open(format=FORMAT,
                channels=CHANNELS,
                rate=RATE,
                input=True,
                frames_per_buffer=CHUNK)

try:
    while True:
        # Read audio data
        data = stream.read(CHUNK, exception_on_overflow=False)
        audio_data = np.frombuffer(data, dtype=np.int16)

        # Perform FFT
        window = np.hanning(len(audio_data))
        windowed = audio_data * window
        fft_result = np.abs(np.fft.rfft(windowed))
        fft_bins = np.interp(fft_result[:16], (0, fft_result.max()), (0, 255)).astype(np.uint8)


        # Create packet with header 'A' indicating FFT data
        packet = b'A' + fft_bins.tobytes()

        # Send UDP packet
        sock.sendto(packet, (ESP32_IP, UDP_PORT))
except KeyboardInterrupt:
    pass
finally:
    stream.stop_stream()
    stream.close()
    p.terminate()
