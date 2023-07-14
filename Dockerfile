FROM ubuntu:22.04
ENV PORT="5000"
ENV GODOT_VERSION="4.1"
ENV GODOT_ARCH="linux.x86_64"
ENV GODOT_EXPORT_PRESET="Linux/X11"
ENV GODOT_PROJECT_NAME="scene_replication"

# Updates and installs to the server
RUN apt-get update
RUN apt-get install bash wget unzip libxcursor-dev libxinerama-dev libxrandr-dev libxi-dev -y

# Download Godot and export template, version is set from variables
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH}.zip
RUN mkdir ~/.cache
RUN mkdir -p ~/.config/godot
RUN unzip Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH}.zip
RUN mv Godot_v${GODOT_VERSION}-stable_${GODOT_ARCH} /usr/local/bin/godot

# Make needed directories for container
RUN mkdir /godotapp
RUN mkdir /godotbuildspace

# # Move to the build space and export the .pck
WORKDIR /godotbuildspace
ADD . .
RUN godot --path /godotbuildspace --headless --export-pack ${GODOT_EXPORT_PRESET} ${GODOT_PROJECT_NAME}.pck
RUN mv ${GODOT_PROJECT_NAME}.pck /godotapp/

# # Change to the godotapp space, delete the source,  and run the app
WORKDIR /godotapp
RUN rm -f -R /godotbuildspace
EXPOSE ${PORT}/udp
CMD godot --headless --main-pack ${GODOT_PROJECT_NAME}.pck