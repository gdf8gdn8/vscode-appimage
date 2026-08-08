# VS Code AppImage Builder

Automated Docker-based build pipeline and `justfile` interface for packaging the latest official Linux release of Visual Studio Code into a standalone `.AppImage` executable.

**Features**

- Rootless Installation: Package VS Code into a single executable that runs without root privileges.
- Docker BuildKit Export: Builds the binary completely isolated inside Docker and outputs the .AppImage directly to your local workspace.
- Command Automation: Simplified task runner interface using just.

**Prerequisites**
Before building, ensure you have the following installed on your host system:
- [Docker](https://docs.docker.com/get-started/get-docker) (with BuildKit enabled)
- [just](https://github.com/casey/just) command runner (optional, but recommended)
- `fuse` (required by Linux to mount and execute AppImages)

#### Quick Start
1. Using `just` (Recommended)  
Build and run the AppImage with a single command:

```Bash
# Build the AppImage into ./out/
just build
# Launch VS Code
just run
```

2. **Installing to User Binaries**
To make the generated AppImage accessible from anywhere in your terminal:

```Bash
just install
```

This copies the binary to `~/.local/bin/vscode-appimage`. Ensure `~/.local/bin` is in your shell's `$PATH`.

#### Available Commands
| Command | Action |
|-------|------|
|`just / just --list`| List all available recipes|
|`just build` | Package VS Code in Docker and export to `./out/VSCode-x86_64.AppImage`|
|just run|Launch the built AppImage (automatically builds if missing)|
|just install|Copy executable to `~/.local/bin/vscode-appimage`|
|just clean|Remove the ./out/ build directory|
` ...` 

#### Manual Docker Usage
If you prefer not to use `just`, you can run the Docker BuildKit pipeline directly:

```Bash
# 1. Build and export the AppImage directly to host directory
docker buildx build --output type=local,dest=./out .
# 2. Make executable
chmod +x ./out/VSCode-x86_64.AppImage`
# 3. Execute
./out/VSCode-x86_64.AppImage`
```

```
Project StructurePlaintext.
├── Dockerfile          # Multi-stage build for downloading VS Code & appimagetool
├── justfile            # Task automation recipes
└── out/                # Build output directory (generated on build)
    └── VSCode-x86_64.AppImage
```

## TroubleshootingFUSE 

**Error on Launch**
If running `./out/VSCode-x86_64.AppImage throws an error regarding libfuse.so.2 or dlopen failed:
- Install FUSE on Debian/Ubuntu: sudo apt install libfuse2
- Install FUSE on Fedora/RHEL: sudo dnf install fuse-libs
- Alternatively, run the AppImage extracted:
 `./out/VSCode-x86_64.AppImage --appimage-extract-and-run`

## License & AI Provenance

This project is licensed under the [MIT License](LICENSE).

This repository contains AI-assisted code generation. For full disclosures on human vs. AI authorship, copyright status, and third-party dependency tracking, see [`PROVENANCE.md`](PROVENANCE.md) and [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md).