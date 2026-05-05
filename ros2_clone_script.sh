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
    echo "  -d, --distro DISTRO      ROS2 distribution (humble, jazzy, kilted, rolling)"
    echo "  -r, --release RELEASE    Specific release tag (optional)"
    echo "  -t, --target DIR         Target directory (default: ros2_ws)"
    echo "  -c, --clean              Clean target directory before cloning"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -d jazzy                     # Latest Jazzy version (recommended LTS)"
    echo "  $0 -d jazzy -r 20260128         # Specific Jazzy patch release (YYYYMMDD)"
    echo "  $0 -d kilted -t my_workspace    # Kilted in custom workspace"
    echo "  $0 -d humble -r 20260220 -c     # Dated patch release with cleanup"
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
    local valid_distros=("humble" "jazzy" "kilted" "rolling")
    
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

# Build the list of candidate refs (branch/tag) to try.
# The ros2/ros2 GitHub repo uses two tag conventions for patch releases:
#   - newer convention (e.g. Jazzy):  release-<distro>-<date>  -> release-jazzy-20260128
#   - older convention (e.g. Humble): <distro>-<date>          -> humble-20250331
# So we try both and keep the first one that resolves to an existing ros2.repos.
build_repos_url() {
    if [[ -n "$RELEASE_TAG" ]]; then
        if [[ "$RELEASE_TAG" =~ ^[0-9]{8}$ ]]; then
            # Date-only argument: try both tag conventions
            CANDIDATE_REFS=(
                "release-${DISTRO}-${RELEASE_TAG}"
                "${DISTRO}-${RELEASE_TAG}"
            )
        else
            # Custom branch/tag passed verbatim by the user
            CANDIDATE_REFS=("$RELEASE_TAG")
        fi
    else
        # No tag specified: use the distribution branch
        CANDIDATE_REFS=("$DISTRO")
    fi

    print_info "Candidate refs: ${CANDIDATE_REFS[*]}"
}

# Check candidate URLs, pick the first one that returns 200, and set REPOS_URL
check_repos_file() {
    print_info "Looking up .repos file..."

    local base_url="https://raw.githubusercontent.com/ros2/ros2"
    local candidate_url

    for ref in "${CANDIDATE_REFS[@]}"; do
        candidate_url="${base_url}/${ref}/ros2.repos"
        print_info "  Trying: $candidate_url"

        if command -v curl &> /dev/null; then
            if curl -s --head "$candidate_url" | head -n 1 | grep -q "200"; then
                REPOS_URL="$candidate_url"
                print_success ".repos file found (ref: ${ref})"
                return 0
            fi
        elif command -v wget &> /dev/null; then
            if wget -q --spider "$candidate_url"; then
                REPOS_URL="$candidate_url"
                print_success ".repos file found (ref: ${ref})"
                return 0
            fi
        fi
    done

    print_error "No .repos file found for distro='${DISTRO}' release='${RELEASE_TAG}'."
    print_error "Tried the following URLs:"
    for ref in "${CANDIDATE_REFS[@]}"; do
        print_error "  - ${base_url}/${ref}/ros2.repos"
    done
    exit 1
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
