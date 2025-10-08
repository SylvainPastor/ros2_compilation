# ROS2 Cross-Compilation Workspace

This workspace provides a complete environment for compiling and cross-compiling ROS2 from source for various target platforms.

## Overview

ROS2 (Robot Operating System 2) is a flexible framework for writing robot software. This repository enables you to:

- **Native compilation**: Build ROS2 from source for your host system
- **Cross-compilation**: Build ROS2 for different target architectures (ARM, ARM64, etc.)
- **Custom configurations**: Tailor the build process to your specific hardware requirements

## Features

- Pre-configured workspace structure for ROS2 source builds
- Cross-compilation toolchain setup and configuration
- Scripts and tools to simplify the build process
- Support for multiple target architectures
- Build optimization options

## Prerequisites

- Ubuntu 22.04 (recommended) or Ubuntu 24.04
- Minimum 4GB RAM (8GB+ recommended for faster builds)
- 20GB+ free disk space
- Basic understanding of ROS2 concepts

### Required Dependencies

```bash
sudo apt update
sudo apt install -y \
    build-essential \
    cmake \
    git \
    python3-pip \
    wget \
    curl
```

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/sylvainpastor/ros2_compilation.git
cd ros2_compilation
```

### 2. Initialize the Workspace

```bash
# Install ROS2 build tools
pip3 install -U \
    colcon-common-extensions \
    vcstool
```

### 3. Download ROS2 source code

```bash
./ros2_clone_script.sh --help
Usage: ./ros2_clone_script.sh [OPTIONS]

Description:
  Clone ROS2 source repositories for a specific distribution and release.
  Useful for synchronizing with meta-ros Yocto builds.

Options:
  -d, --distro DISTRO      ROS2 distribution (humble, iron, jazzy, rolling)
  -r, --release RELEASE    Specific release tag (optional)
  -t, --target DIR         Target directory (default: ros2_ws)
  -c, --clean              Clean target directory before cloning
  -h, --help               Show this help message

Examples:
  ./ros2_clone_script.sh -d humble                    # Latest Humble version
  ./ros2_clone_script.sh -d humble -r release/humble  # Specific Humble release
  ./ros2_clone_script.sh -d iron -t my_workspace      # Iron in custom workspace
  ./ros2_clone_script.sh -d humble -r 20230417 -c     # Dated release with cleanup

Notes:
  - For meta-ros synchronization, use the exact tag/commit from meta-ros
  - The script validates URLs before cloning
  - Requires vcstool, git, and curl/wget to be installed
```

Example usage:

```bash
# Example: humble distribution, release date 2025-03-31 and target directory ros2_ws
./ros2_clone_script.sh -d humble -t ros2_ws -r 20250331
```

### 4. Native Compilation

To build ROS2 for your host system:

**Option 1: Using colcon directly**

```bash
cd ros2_ws
# Build
colcon build --symlink-install
```

**Option 2: Using the provided Makefile**

```bash
# Copy
cp Makefile ros2_ws
cd ros2_ws
make
```
Expected output:

```bash
...
Summary: 346 packages finished [17min 41s]
```

### 5. Cross-Compilation

TODO: Documentation coming soon.

## License

This project is licensed under the MIT - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Resources

- [ROS2 Documentation](https://docs.ros.org/)
- [ROS2 Building from Source](https://docs.ros.org/en/rolling/Installation/Alternatives/Ubuntu-Development-Setup.html)
