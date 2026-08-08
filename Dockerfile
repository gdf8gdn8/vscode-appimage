# Stage 1: Download VS Code and package the AppImage
FROM ubuntu:26.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install packaging tools and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    file \
    squashfs-tools \
    binutils \
    desktop-file-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download appimagetool
RUN curl -sSL https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -o /usr/local/bin/appimagetool && \
    chmod +x /usr/local/bin/appimagetool

WORKDIR /build

# Fetch and unpack the latest stable VS Code Linux tarball
RUN curl -sSL "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -o vscode.tar.gz && \
    mkdir -p VSCode.AppDir/usr/lib/vscode && \
    tar -xzf vscode.tar.gz -C VSCode.AppDir/usr/lib/vscode --strip-components=1 && \
    rm vscode.tar.gz

# Set up binary directory symlink
RUN mkdir -p VSCode.AppDir/usr/bin && \
    ln -s ../lib/vscode/code VSCode.AppDir/usr/bin/code

# Create AppRun entrypoint script
RUN echo '#!/bin/bash\n\
HERE="$(dirname "$(readlink -f "${0}")")"\n\
export PATH="${HERE}/usr/bin:${PATH}"\n\
export LD_LIBRARY_PATH="${HERE}/usr/lib/vscode:${LD_LIBRARY_PATH}"\n\
exec "${HERE}/usr/lib/vscode/code" "$@"' > VSCode.AppDir/AppRun && \
    chmod +x VSCode.AppDir/AppRun

# Copy application icons and desktop entry file
RUN cp VSCode.AppDir/usr/lib/vscode/resources/app/resources/linux/code.png VSCode.AppDir/code.png && \
    cp VSCode.AppDir/usr/lib/vscode/resources/app/resources/linux/code.png VSCode.AppDir/.DirIcon && \
    echo '[Desktop Entry]\n\
Name=Visual Studio Code\n\
Comment=Code Editing. Redefined.\n\
Exec=code %F\n\
Icon=code\n\
Type=Application\n\
StartupNotify=false\n\
StartupWMClass=Code\n\
Categories=Development;IDE;\n\
MimeType=text/plain;' > VSCode.AppDir/code.desktop

# Build the AppImage (using --appimage-extract-and-run to bypass FUSE requirements inside Docker)
RUN ARCH=x86_64 /usr/local/bin/appimagetool --appimage-extract-and-run VSCode.AppDir VSCode-x86_64.AppImage

# Stage 2: Export output stage for Docker BuildKit
FROM scratch AS export
COPY --from=builder /build/VSCode-x86_64.AppImage /