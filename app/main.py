import socket
import time

WLED_IP = "192.168.50.147"  # Replace with your actual WLED IP
WLED_PORT = 21324
LED_COUNT = 60            # Match your LED count

def send_color(r, g, b):
    data = bytes([val for _ in range(LED_COUNT) for val in (r, g, b)])
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(data, (WLED_IP, WLED_PORT))

if __name__ == "__main__":
    print("🔴 Flashing RED")
    send_color(255, 0, 0)
    time.sleep(1)
    
    print("🟢 Flashing GREEN")
    send_color(0, 255, 0)
    time.sleep(1)
    
    print("🔵 Flashing BLUE")
    send_color(0, 0, 255)
    time.sleep(1)

    print("⚫️ Turning OFF")
    send_color(0, 0, 0)