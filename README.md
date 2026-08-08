VS Code AppImage BuilderAutomated Docker-based build pipeline and justfile interface for packaging the latest official Linux release of Visual Studio Code into a standalone .AppImage executable.FeaturesRootless Installation: Package VS Code into a single executable that runs without root privileges.Docker BuildKit Export: Builds the binary completely isolated inside Docker and outputs the .AppImage directly to your local workspace.Command Automation: Simplified task runner interface using just.PrerequisitesBefore building, ensure you have the following installed on your host system:Docker (with BuildKit enabled)just command runner (optional, but recommended)fuse (required by Linux to mount and execute AppImages)Quick Start1. Using just (Recommended)Build and run the AppImage with a single command:Bash# Build the AppImage into ./out/
just build

# Launch VS Code
just run
2. Installing to User BinariesTo make the generated AppImage accessible from anywhere in your terminal:Bashjust install
This copies the binary to ~/.local/bin/vscode-appimage. Ensure ~/.local/bin is in your shell's $PATH.Available CommandsCommandActionjust / just --listList all available recipesjust buildPackage VS Code in Docker and export to ./out/VSCode-x86_64.AppImagejust runLaunch the built AppImage (automatically builds if missing)just installCopy executable to ~/.local/bin/vscode-appimagejust cleanRemove the ./out/ build directoryManual Docker UsageIf you prefer not to use just, you can run the Docker BuildKit pipeline directly:Bash# 1. Build and export the AppImage directly to host directory
docker buildx build --output type=local,dest=./out .

# 2. Make executable
chmod +x ./out/VSCode-x86_64.AppImage

# 3. Execute
./out/VSCode-x86_64.AppImage
Project StructurePlaintext.
├── Dockerfile          # Multi-stage build for downloading VS Code & appimagetool
├── justfile            # Task automation recipes
└── out/                # Build output directory (generated on build)
    └── VSCode-x86_64.AppImage
TroubleshootingFUSE Error on LaunchIf running ./out/VSCode-x86_64.AppImage throws an error regarding libfuse.so.2 or dlopen failed:Install FUSE on Debian/Ubuntu: sudo apt install libfuse2Install FUSE on Fedora/RHEL: sudo dnf install fuse-libsAlternatively, run the AppImage extracted: ./out/VSCode-x86_64.AppImage --appimage-extract-and-run# vscode-appimage-
