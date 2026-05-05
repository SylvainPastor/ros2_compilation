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

## Supported ROS 2 Distributions

Each ROS 2 distribution targets exactly one Ubuntu LTS as a Tier 1 platform. Use the tables below to choose a value for the `-d` option of `ros2_clone_script.sh` and to make sure your host Ubuntu version matches.

### Currently supported

| ROS 2 Distribution | Release date | EOL date | Ubuntu (Tier 1) | Type |
|---|---|---|---|---|
| **Rolling Ridley** | continuous | - | Ubuntu 24.04 (Noble) | development |
| **Kilted Kaiju** | May 23, 2025 | December 2026 | Ubuntu 24.04 (Noble) | non-LTS |
| **Jazzy Jalisco** | May 23, 2024 | May 2029 | Ubuntu 24.04 (Noble) | LTS (5 years) |
| **Humble Hawksbill** | May 23, 2022 | May 2027 | Ubuntu 22.04 (Jammy) | LTS (5 years) |

### Upcoming

| ROS 2 Distribution | Expected release | Expected EOL | Ubuntu (Tier 1) |
|---|---|---|---|
| **Lyrical Luth** | May 2026 | May 2031 | Ubuntu 24.04 (Noble) - LTS |

### End-of-life

| ROS 2 Distribution | Release date | EOL date | Ubuntu (Tier 1) |
|---|---|---|---|
| Iron Irwini | May 2023 | December 2024 | Ubuntu 22.04 (Jammy) |
| Galactic Geochelone | May 2021 | December 2022 | Ubuntu 20.04 (Focal) |
| Foxy Fitzroy | June 2020 | June 2023 | Ubuntu 20.04 (Focal) |
| Eloquent Elusor | November 2019 | November 2020 | Ubuntu 18.04 (Bionic) |
| Dashing Diademata | May 2019 | May 2021 | Ubuntu 18.04 (Bionic) |
| Crystal Clemmys | December 2018 | December 2019 | Ubuntu 18.04 (Bionic) |
| Bouncy Bolson | July 2018 | July 2019 | Ubuntu 18.04 (Bionic) |
| Ardent Apalone | December 2017 | December 2018 | Ubuntu 16.04 (Xenial) |

### Key rules

- A new ROS 2 distribution is released every year on **May 23rd** (World Turtle Day).
- Each ROS 2 release is supported on **exactly one Ubuntu LTS**.
- **LTS** ROS 2 releases (even years, starting with Humble) are supported for **5 years**.
- **Non-LTS** ROS 2 releases are supported for ~**18 months**.
- Odd-year ROS 2 releases share the Ubuntu LTS of the previous year's LTS ROS 2 release.

### Recommendation

- New project → **Jazzy Jalisco on Ubuntu 24.04** (supported until May 2029).
- Existing project / legacy code → **Humble Hawksbill on Ubuntu 22.04** (supported until May 2027).

### References

- [ROS 2 Distributions list](https://docs.ros.org/en/rolling/Releases.html)
- [ROS 2 Platform EOL Policy](https://docs.ros.org/en/rolling/The-ROS2-Project/Platform-EOL-Policy.html)
- [ROS 2 Release Schedule](https://docs.ros.org/en/rolling/The-ROS2-Project/Release-Schedule.html)
- [REP 2000 - Target platforms per distribution](https://www.ros.org/reps/rep-2000.html)
- [endoflife.date - ROS 2](https://endoflife.date/ros-2)

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
