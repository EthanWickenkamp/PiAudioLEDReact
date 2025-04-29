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
    libasound2-dev \
    libopenblas0 \
    libportaudio2 \
    libportaudio-dev \
    python3 \
    python3-dbus \
    python3-pip \
    build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python libraries
RUN pip install numpy sounddevice pyaudio

# Create non-root user and add to audio group, no password
RUN useradd -ms /bin/bash audiouser && \
    usermod -aG audio audiouser && \
    passwd -d audiouser

# Set working directory and copy app files
WORKDIR /app
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default startup command
CMD ["/bin/bash", "/entrypoint.sh"]
