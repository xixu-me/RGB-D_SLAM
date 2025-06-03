# RGB-D SLAM

A real-time Simultaneous Localization and Mapping (SLAM) system using RGB-D camera data, implemented in C++ with visual odometry and 3D visualization.

## 🎯 Overview

This project implements a visual SLAM system that processes RGB-D (color + depth) image sequences to estimate camera motion and build a 3D map of the environment. The system uses feature-based visual odometry with ORB features and PnP pose estimation, providing real-time 3D visualization using Pangolin.

## 🚀 Features

- **Real-time RGB-D SLAM** processing
- **Visual Odometry** using ORB feature detection and matching
- **Pose Estimation** via PnP RANSAC algorithm  
- **3D Map Building** with colored point clouds
- **Interactive Visualization** using Pangolin with GUI controls
- **Multi-threaded Architecture** for optimal performance
- **TUM RGB-D Dataset** compatibility
- **Configurable Parameters** via YAML configuration

## 🛠️ Dependencies

### Required Libraries

- **OpenCV** (≥ 4.0) - Computer vision and image processing
- **Pangolin** - 3D visualization and GUI
- **Eigen3** - Linear algebra operations
- **CMake** (≥ 3.5) - Build system

### System Requirements

- **C++23** compatible compiler
- **Linux/WSL2** (tested on Ubuntu)
- **OpenGL** support for visualization

## 📦 Installation

### 1. Install Dependencies

#### Ubuntu/WSL2

```bash
# Update package list
sudo apt update

# Install OpenCV
sudo apt install libopencv-dev

# Install Eigen3
sudo apt install libeigen3-dev

# Install Pangolin dependencies
sudo apt install libgl1-mesa-dev libglew-dev cmake
sudo apt install libpython2.7-dev pkg-config

# Build and install Pangolin
git clone https://github.com/stevenlovegrove/Pangolin.git
cd Pangolin
mkdir build && cd build
cmake ..
make -j4
sudo make install
```

### 2. Clone and Build Project

```bash
# Clone repository
git clone https://github.com/xixu-me/RGB-D_SLAM.git
cd RGB-D_SLAM

# Create build directory
mkdir build && cd build

# Configure and build
cmake ..
make -j4
```

### 3. Setup Dataset

Download the TUM RGB-D dataset:

```bash
# Create dataset directory
mkdir -p dataset

# Download sample dataset (freiburg1_xyz)
wget https://vision.in.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz
tar -xzf rgbd_dataset_freiburg1_xyz.tgz -C dataset/

# Generate association file
cd dataset/rgbd_dataset_freiburg1_xyz
python ../../associate.py rgb.txt depth.txt > associate.txt
cd ../..
```

## 🚀 Usage

### Quick Start

```bash
# Run with default configuration
./out/bin/slam_app config.yaml

# Or use the automated script
chmod +x compile_and_run.sh
./compile_and_run.sh
```

### Configuration

Edit `config.yaml` to customize parameters:

```yaml
%YAML:1.0

# Dataset path
dataset_dir: ./dataset/rgbd_dataset_freiburg1_xyz

# Visualization settings
pointSizeCur: 3.15    # Current frame point size
pointSizeHis: 2.75    # Historical point size
waitTime: 1           # Display delay (ms)

# Dense mapping (0=sparse, 1=dense)
dense: 0
```

### GUI Controls

The Pangolin visualization provides interactive controls:

- **Follow Camera**: Toggle camera following mode
- **Show Points**: Toggle 3D point cloud display
- **Show KeyFrames**: Toggle camera trajectory display  
- **Only CurFrames**: Show only current frame or full trajectory

### Camera Controls

- **Left Click + Drag**: Rotate view
- **Right Click + Drag**: Pan view
- **Scroll Wheel**: Zoom in/out
- **Middle Click**: Reset view

## 🏗️ Architecture

### Core Components

```
├── Vo (Visual Odometry)
│   ├── Feature Extraction (ORB)
│   ├── Feature Matching (BF Matcher)
│   ├── Pose Estimation (PnP RANSAC)
│   └── Map Point Management
├── Config (Configuration Manager)
├── Frame (Data Structure)
├── MapPoint (3D Point Representation)
└── Visualization (Pangolin Thread)
```

### Data Flow

1. **Frame Loading**: Read RGB and depth images from dataset
2. **Feature Extraction**: Detect ORB keypoints and compute descriptors
3. **Feature Matching**: Match features between consecutive frames
4. **Pose Estimation**: Estimate camera motion using PnP RANSAC
5. **Map Update**: Add new 3D points to the map
6. **Visualization**: Render trajectory and point cloud in real-time

### Multi-threading

- **Main Thread**: Pangolin visualization and GUI
- **Worker Thread**: Data processing and SLAM computation
- **Synchronization**: Condition variables and mutexes for thread safety

## 📊 Algorithm Details

### Feature Detection

- **ORB Features**: Fast and rotation-invariant
- **2600 keypoints** per frame for robust matching
- **Binary descriptors** for efficient matching

### Pose Estimation

- **PnP RANSAC**: Robust pose estimation from 3D-2D correspondences
- **Camera intrinsics**: Fixed parameters for TUM dataset
- **Depth integration**: Convert 2D features to 3D using depth information

### Map Building

- **Sparse mapping**: Feature-based 3D reconstruction
- **Point cloud**: Colored 3D points from RGB-D data
- **Memory management**: Optional point removal for efficiency

## 🎮 WSL2 GUI Setup

For WSL2 users, GUI applications require X server setup:

### Option 1: Windows 11 with WSLg (Recommended)

- Automatic GUI support - no additional setup needed

### Option 2: External X Server

Install an X server on Windows:

- **VcXsrv** (free): <https://sourceforge.net/projects/vcxsrv/>
- **X410** (paid): Microsoft Store
- **Xming** (free): <https://sourceforge.net/projects/xming/>

Set display variable:

```bash
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
# OR
export DISPLAY=:0
```

## 📝 File Structure

```
RGB-D_SLAM/
├── CMakeLists.txt          # Build configuration
├── config.yaml             # Runtime configuration
├── compile_and_run.sh      # Automated build script
├── include/                # Header files
│   ├── common_include.h    # Common includes and utilities
│   ├── config.hpp          # Configuration management
│   ├── DS.h                # Data structures
│   ├── utils.h             # Utility functions
│   └── Vo.h                # Visual odometry class
├── src/                    # Source files
│   ├── utils.cpp           # Utility implementations
│   └── Vo.cpp              # Main SLAM implementation
├── Main/                   # Application entry point
│   └── main.cpp            # Main function
├── dataset/                # Dataset directory
│   └── rgbd_dataset_freiburg1_xyz/
└── out/                    # Build outputs
    ├── bin/                # Executables
    └── libs/               # Libraries
```

## 🔧 Troubleshooting

### Common Issues

**OpenGL/Pangolin errors:**

```bash
# Install missing OpenGL libraries
sudo apt install mesa-utils
# Test OpenGL
glxinfo | grep OpenGL
```

**Missing dataset:**

- Ensure `associate.txt` exists in dataset directory
- Check file paths in `config.yaml`
- Verify dataset format matches TUM RGB-D specification

**Build errors:**

- Check C++23 compiler support
- Verify all dependencies are installed
- Clear build directory and rebuild

### Performance Tips

- Reduce `pointSizeCur` and `pointSizeHis` for better performance
- Set `dense: 0` for sparse mapping (faster)
- Increase `waitTime` to slow down processing
- Close other applications to free system resources

## 📚 Dataset Format

The system expects TUM RGB-D dataset format:

```
dataset/rgbd_dataset_freiburg1_xyz/
├── rgb/                    # RGB images
│   ├── 1305031102.160407.png
│   └── ...
├── depth/                  # Depth images  
│   ├── 1305031102.160407.png
│   └── ...
├── rgb.txt                 # RGB timestamps
├── depth.txt               # Depth timestamps
├── associate.txt           # Associated RGB-Depth pairs
├── groundtruth.txt         # Camera poses (optional)
└── accelerometer.txt       # IMU data (optional)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- **TUM RGB-D Dataset**: Technical University of Munich for providing the dataset
- **Pangolin**: Steven Lovegrove for the visualization library
- **OpenCV**: Computer vision community for the comprehensive library
- **Eigen**: Linear algebra template library

## 📞 Support

For questions and issues:

1. Check the troubleshooting section
2. Review existing issues in the repository
3. Create a new issue with detailed description

## License

Copyright &copy; [Xi Xu](https://xi-xu.me). All rights reserved.

Licensed under the [GPL-3.0](LICENSE) license.  
