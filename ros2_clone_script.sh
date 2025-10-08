#!/bin/bash

# ROS2 Source Cloning Script - Clone ROS2 sources for specific releases
# 
# Purpose: Clone ROS2 source code repositories for a specific distribution and release
# This script helps synchronize with the exact same sources used in meta-ros for Yocto builds
#
# Author: spastor
# Dependencies: vcstool, git, curl/wget
# Usage: ./clone_ros2_release.sh [OPTIONS]

set -e

################################################################################################

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display functions with color coding
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################################

# Help function - displays usage information
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Description:"
    echo "  Clone ROS2 source repositories for a specific distribution and release."
    echo "  Useful for synchronizing with meta-ros Yocto builds."
    echo ""
    echo "Options:"
    echo "  -d, --distro DISTRO      ROS2 distribution (humble, iron, jazzy, rolling)"
    echo "  -r, --release RELEASE    Specific release tag (optional)"
    echo "  -t, --target DIR         Target directory (default: ros2_ws)"
    echo "  -c, --clean              Clean target directory before cloning"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -d humble                    # Latest Humble version"
    echo "  $0 -d humble -r release/humble  # Specific Humble release"
    echo "  $0 -d iron -t my_workspace      # Iron in custom workspace"
    echo "  $0 -d humble -r 2023.04.17 -c   # Dated release with cleanup"
    echo ""
    echo "Notes:"
    echo "  - For meta-ros synchronization, use the exact tag/commit from meta-ros"
    echo "  - The script validates URLs before cloning"
    echo "  - Requires vcstool, git, and curl/wget to be installed"
}

################################################################################################

# Default values
DISTRO=""
RELEASE_TAG=""
TARGET_DIR="ros2_ws"
CLEAN_TARGET=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--distro)
            DISTRO="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_TAG="$2"
            shift 2
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_TARGET=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

################################################################################################

# Prerequisites check - verify required tools are installed
check_requirements() {
    print_info "Checking prerequisites..."
    
    if ! command -v vcs &> /dev/null; then
        print_error "vcstool is not installed. Install it with: pip install vcstool"
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        print_error "git is not installed."
        exit 1
    fi
    
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        print_error "curl or wget is required."
        exit 1
    fi
    
    print_success "Prerequisites OK"
}

# Validate ROS2 distribution name
validate_distro() {
    local valid_distros=("humble" "iron" "jazzy" "rolling")
    
    if [[ -z "$DISTRO" ]]; then
        print_error "Distribution not specified. Use -d or --distro"
        show_help
        exit 1
    fi
    
    if [[ ! " ${valid_distros[@]} " =~ " ${DISTRO} " ]]; then
        print_error "Invalid distribution: $DISTRO"
        print_info "Supported distributions: ${valid_distros[*]}"
        exit 1
    fi
}

# Build the .repos file URL based on distribution and release
build_repos_url() {
    local base_url="https://raw.githubusercontent.com/ros2/ros2"
    
    if [[ -n "$RELEASE_TAG" ]]; then
        REPOS_URL="${base_url}/${DISTRO}-${RELEASE_TAG}/ros2.repos"
    else
        REPOS_URL="${base_url}/${DISTRO}/ros2.repos"
    fi
    
    print_info "Repos file URL: $REPOS_URL"
}

# Check if the .repos file exists at the specified URL
check_repos_file() {
    print_info "Checking .repos file existence..."
    
    if command -v curl &> /dev/null; then
        if ! curl -s --head "$REPOS_URL" | head -n 1 | grep -q "200"; then
            print_error "The .repos file does not exist at URL: $REPOS_URL"
            exit 1
        fi
    elif command -v wget &> /dev/null; then
        if ! wget -q --spider "$REPOS_URL"; then
            print_error "The .repos file does not exist at URL: $REPOS_URL"
            exit 1
        fi
    fi
    
    print_success ".repos file found"
}

# Prepare target directory for cloning
prepare_target_dir() {
    if [[ "$CLEAN_TARGET" = true ]] && [[ -d "$TARGET_DIR" ]]; then
        print_warning "Cleaning target directory $TARGET_DIR..."
        rm -rf "$TARGET_DIR"
    fi
    
    mkdir -p "$TARGET_DIR/src"
    cd "$TARGET_DIR"
    
    print_info "Working directory: $(pwd)"
}

# Clone ROS2 source repositories
clone_sources() {
    print_info "Starting ROS2 source cloning..."
    print_info "Distribution: $DISTRO"
    if [[ -n "$RELEASE_TAG" ]]; then
        print_info "Release: $RELEASE_TAG"
    fi
    
    # Import repositories using vcstool
    if vcs import --input "$REPOS_URL" src; then
        print_success "Cloning completed successfully"
    else
        print_error "Error during cloning"
        exit 1
    fi
}

# Display post-cloning summary and information
show_summary() {
    print_info "Cloning summary:"
    echo "  - Distribution: $DISTRO"
    if [[ -n "$RELEASE_TAG" ]]; then
        echo "  - Release: $RELEASE_TAG"
    fi
    echo "  - Directory: $(pwd)"
    echo "  - Number of packages: $(find src -name "package.xml" | wc -l)"
    
    print_info "Repository information:"
    vcs status src
    
    print_success "ROS2 workspace ready in: $(pwd)"
    print_info "To build: colcon build"
}

################################################################################################

# Main function - orchestrates the entire cloning process
main() {
    print_info "=== ROS2 Source Cloning Script ==="
    
    check_requirements
    validate_distro
    build_repos_url
    check_repos_file
    prepare_target_dir
    clone_sources
    show_summary
    
    print_success "=== Cloning completed successfully ==="
}

# Signal handling - clean exit on interrupt
trap 'print_error "Script interrupted by user"; exit 1' INT TERM

# Script execution
main "$@"