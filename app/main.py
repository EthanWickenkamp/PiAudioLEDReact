import socket

WLED_IP = "192.168.50.147"  # Replace with your WLED's IP
WLED_PORT = 21324
LED_COUNT = 60            # Match your setup
COLOR = [255, 0, 0]       # Bright Red

def send_color(rgb):
    packet = bytes([val for _ in range(LED_COUNT) for val in rgb])
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(packet, (WLED_IP, WLED_PORT))

if __name__ == "__main__":
    print("🌈 Sending static color to WLED...")
    send_color(COLOR)
    print("✅ Done!")
