# Justfile for building and managing VS Code AppImage via Docker

out_dir := "out"
appimage := out_dir + "/VSCode-x86_64.AppImage"
user_bin := env_var('HOME') + "/.local/bin"
apps_dir := env_var('HOME') + "/.local/share/applications"
icons_dir := env_var('HOME') + "/.local/share/icons/hicolor/128x128/apps"

# Default recipe: show available commands
default:
    @just --list

# Build the VS Code AppImage via Docker and export to ./out/
build:
    @echo "==> Building VS Code AppImage in Docker..."
    mkdir -p {{out_dir}}
    docker buildx build --output type=local,dest={{out_dir}} .
    chmod +x {{appimage}}
    @echo "==> Successfully created {{appimage}}"

# Run the generated AppImage
run:
    @if [ ! -f {{appimage}} ]; then \
        echo "AppImage not found. Building now..."; \
        just build; \
    fi
    @echo "==> Launching VS Code..."
    ./{{appimage}}

# Install the AppImage binary to ~/.local/bin
install: build
    mkdir -p {{user_bin}}
    cp {{appimage}} {{user_bin}}/vscode-appimage
    @echo "==> Installed binary as 'vscode-appimage' in {{user_bin}}"

# Add desktop integration (application menu entry and icon)
integrate: install
    @echo "==> Setting up desktop menu entry and icon..."
    mkdir -p {{apps_dir}}
    mkdir -p {{icons_dir}}
    @# Extract icon from AppImage if available
    @if [ -f {{appimage}} ]; then \
        ./{{appimage}} --appimage-extract code.png >/dev/null 2>&1 || true; \
        if [ -f squashfs-root/code.png ]; then \
            cp squashfs-root/code.png {{icons_dir}}/vscode-appimage.png; \
            rm -rf squashfs-root; \
        fi \
    fi
    @echo '[Desktop Entry]' > {{apps_dir}}/vscode-appimage.desktop
    @echo 'Name=VS Code (AppImage)' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Comment=Code Editing. Redefined.' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Exec={{user_bin}}/vscode-appimage %F' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Icon=vscode-appimage' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Type=Application' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Terminal=false' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'StartupNotify=true' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'StartupWMClass=Code' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'Categories=Development;IDE;' >> {{apps_dir}}/vscode-appimage.desktop
    @echo 'MimeType=text/plain;inode/directory;' >> {{apps_dir}}/vscode-appimage.desktop
    @if command -v update-desktop-database >/dev/null 2>&1; then \
        update-desktop-database {{apps_dir}}; \
    fi
    @echo "==> Desktop integration complete! Shortcut added to {{apps_dir}}/vscode-appimage.desktop"

# Remove desktop integration shortcut and icon
unintegrate:
    rm -f {{apps_dir}}/vscode-appimage.desktop
    rm -f {{icons_dir}}/vscode-appimage.png
    @if command -v update-desktop-database >/dev/null 2>&1; then \
        update-desktop-database {{apps_dir}}; \
    fi
    @echo "==> Desktop integration removed."

# Remove build output artifacts and local installed binary
clean: unintegrate
    rm -rf {{out_dir}}
    rm -f {{user_bin}}/vscode-appimage
    @echo "==> Cleaned build output and installed files."