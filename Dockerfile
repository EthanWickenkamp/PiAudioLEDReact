# Base image
FROM balenalib/raspberrypi3-debian:bullseye

# Install system & audio dependencies (with OpenBLAS for numpy)
RUN apt-get update && apt-get install -y \
    alsa-utils \
    pulseaudio \
    pulseaudio-utils \
    pulseaudio-module-bluetooth \
    bluetooth \
    bluez \
    dbus \
    libasound2 \
    libopenblas0 \
    python3 \
    python3-dbus \
    python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python libraries
RUN pip install numpy sounddevice

# Create non-root user and add to audio group, no password
RUN useradd -ms /bin/bash audiouser && \
    usermod -aG audio audiouser && \
    passwd -d audiouser

# Set working directory and copy app files
WORKDIR /app
COPY app/ /app/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default startup command
CMD ["/bin/bash", "/entrypoint.sh"]
