#!/bin/bash

# =============================================================================
# Compile and Run Script for tiny_slam_rgbd C++ Project
# For Ubuntu 24.04 LTS in WSL2 with GUI support
# =============================================================================

set -e # Exit immediately if a command exits with a non-zero status

echo "=== tiny_slam_rgbd Compilation and Setup Script ==="
echo "Starting setup for Ubuntu 24.04 LTS WSL2..."
echo "This script will install dependencies, compile Pangolin from source,"
echo "and build the SLAM application. This may take 5-15 minutes."
echo ""

# =============================================================================
# 1. Update and Upgrade System Packages
# =============================================================================
echo "Step 1: Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

# =============================================================================
# 2. Install Essential Build Tools and Dependencies
# =============================================================================
echo "Step 2: Installing essential build tools and dependencies..."

# Install basic build tools
sudo apt install -y build-essential git cmake

# Install Python3 (needed for associate.py script)
echo "Installing Python3..."
sudo apt install -y python3

# Install wheel (needed for Pangolin compilation)
echo "Installing Python wheel..."
sudo apt install -y python3-wheel

# Install OpenCV development libraries
echo "Installing OpenCV development libraries..."
sudo apt install -y libopencv-dev

# Install Eigen3 development libraries
echo "Installing Eigen3 development libraries..."
sudo apt install -y libeigen3-dev

# Install OpenGL and X11 dependencies for Pangolin
echo "Installing OpenGL, X11, and related dependencies..."
sudo apt install -y \
    libglew-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    libx11-dev \
    libxmu-dev \
    libxi-dev \
    libxrandr-dev \
    libepoxy-dev \
    python3-dev

# =============================================================================
# 3. Install Pangolin from Source (required dependency)
# =============================================================================
echo "Step 3: Installing Pangolin library from source..."

# Create temporary directory for Pangolin build
TEMP_DIR="/tmp/pangolin_build"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Clone Pangolin repository
echo "Cloning Pangolin repository..."
git clone --recursive https://github.com/stevenlovegrove/Pangolin.git
cd Pangolin

# Create build directory and compile
echo "Compiling Pangolin..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)

# Install Pangolin
echo "Installing Pangolin..."
sudo make install

# Update library cache
sudo ldconfig

# Clean up temporary directory
cd /
rm -rf "$TEMP_DIR"

echo "Pangolin installation completed."

# =============================================================================
# 4. Project Directory and Compilation
# =============================================================================
echo "Step 4: Compiling tiny_slam_rgbd project..."

# Ensure we're in the project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "Project directory: $PROJECT_ROOT"

# Create build directory
echo "Creating build directory..."
mkdir -p build
cd build

# Configure with CMake
echo "Configuring project with CMake..."
cmake ..

# Compile the project
echo "Compiling project..."
make -j$(nproc)

# Return to project root
cd "$PROJECT_ROOT"

# =============================================================================
# 5. Generate Associate File if Missing
# =============================================================================
echo "Step 5: Checking and generating associate.txt file..."

DATASET_DIR="dataset/rgbd_dataset_freiburg1_xyz"
ASSOCIATE_FILE="$DATASET_DIR/associate.txt"

if [ ! -f "$ASSOCIATE_FILE" ]; then
    echo "Associate file not found. Generating from rgb.txt and depth.txt..."

    if [ ! -f "$DATASET_DIR/rgb.txt" ] || [ ! -f "$DATASET_DIR/depth.txt" ]; then
        echo "✗ Error: rgb.txt or depth.txt not found in $DATASET_DIR"
        echo "Please ensure the TUM RGB-D dataset is properly extracted in the dataset directory."
        exit 1
    fi

    # Make associate.py executable
    chmod +x associate.py

    # Generate associate.txt file
    python3 associate.py "$DATASET_DIR/rgb.txt" "$DATASET_DIR/depth.txt" >"$ASSOCIATE_FILE"

    if [ -f "$ASSOCIATE_FILE" ]; then
        echo "✓ Associate file generated successfully: $ASSOCIATE_FILE"
    else
        echo "✗ Failed to generate associate file"
        exit 1
    fi
else
    echo "✓ Associate file already exists: $ASSOCIATE_FILE"
fi

# =============================================================================
# 6. Post-Compilation Check
# =============================================================================
echo "Step 6: Verifying compilation..."

if [ -f "out/bin/slam_app" ]; then
    echo "✓ Compilation successful! Executable created at: out/bin/slam_app"

    # Check if dataset exists
    if [ -d "$DATASET_DIR" ]; then
        echo "✓ Dataset directory found: $DATASET_DIR"
    else
        echo "⚠ Warning: Dataset directory not found: $DATASET_DIR"
        echo "  Please ensure you have the TUM RGB-D dataset extracted in the correct location."
    fi

    # Check if config file exists
    if [ -f "config.yaml" ]; then
        echo "✓ Configuration file found: config.yaml"
    else
        echo "⚠ Warning: Configuration file not found: config.yaml"
    fi

else
    echo "✗ Compilation failed! Executable not found."
    echo "Check the build output above for error messages."
    exit 1
fi

# =============================================================================
# 7. WSL2 GUI Setup Instructions and Execution Guide
# =============================================================================
echo ""
echo "=== Setup Complete! ==="
echo ""
echo "To run the SLAM application:"
echo "  ./out/bin/slam_app config.yaml"
echo ""
echo "=== WSL2 GUI Requirements ==="
echo "For GUI applications like Pangolin to work in WSL2, ensure you have:"
echo ""
echo "1. Windows 11 with WSLg (recommended - automatic GUI support)"
echo "   OR"
echo "2. An X server running on your Windows host:"
echo "   - VcXsrv (free): https://sourceforge.net/projects/vcxsrv/"
echo "   - X410 (paid): Microsoft Store"
echo "   - Xming (free): https://sourceforge.net/projects/xming/"
echo ""
echo "If using an external X server, you may need to set DISPLAY manually:"
echo "  export DISPLAY=\$(cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'):0.0"
echo "  # OR simply:"
echo "  export DISPLAY=:0"
echo ""
echo "=== Dataset Configuration ==="
echo "The config.yaml file is pre-configured to use the dataset at:"
echo "  ./dataset/rgbd_dataset_freiburg1_xyz"
echo ""
echo "Make sure this dataset exists in the correct location before running."
echo ""
echo "=== Running the Application ==="
echo "From the project root directory, execute:"
echo "  ./out/bin/slam_app config.yaml"
echo ""
echo "The application will:"
echo "- Load RGB-D data from the configured dataset"
echo "- Perform real-time SLAM processing"
echo "- Display 3D visualization using Pangolin"
echo "- Show progress and transformation estimates"
echo ""
echo "Press Ctrl+C to stop the application when needed."
echo ""
echo "Setup script completed successfully!"
