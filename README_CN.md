# RGB-D SLAM

一个使用 RGB-D 相机数据的实时同步定位与地图构建 (SLAM) 系统，采用 C++ 实现，具备视觉里程计和 3D 可视化功能。

## 🎯 项目概述

本项目实现了一个视觉 SLAM 系统，能够处理 RGB-D（彩色 + 深度）图像序列来估计相机运动并构建环境的 3D 地图。系统采用基于特征的视觉里程计，使用 ORB 特征和 PnP 位姿估计，通过 Pangolin 提供实时 3D 可视化。

## 🚀 主要特性

- **实时 RGB-D SLAM** 处理
- **视觉里程计**，使用 ORB 特征检测和匹配
- **位姿估计**，通过 PnP RANSAC 算法
- **3D 地图构建**，带有彩色点云
- **交互式可视化**，使用 Pangolin 与 GUI 控制
- **多线程架构**，实现最佳性能
- **TUM RGB-D 数据集**兼容性
- **可配置参数**，通过 YAML 配置文件

## 🛠️ 依赖项

### 必需库

- **OpenCV** (≥ 4.0) - 计算机视觉和图像处理
- **Pangolin** - 3D 可视化和 GUI
- **Eigen3** - 线性代数运算
- **CMake** (≥ 3.5) - 构建系统

### 系统要求

- **C++23** 兼容编译器
- **Linux/WSL2**（在 Ubuntu 上测试）
- **OpenGL** 可视化支持

## 📦 安装说明

### 1. 安装依赖项

#### Ubuntu/WSL2

```bash
# 更新包列表
sudo apt update

# 安装 OpenCV
sudo apt install libopencv-dev

# 安装 Eigen3
sudo apt install libeigen3-dev

# 安装 Pangolin 依赖项
sudo apt install libgl1-mesa-dev libglew-dev cmake
sudo apt install libpython2.7-dev pkg-config

# 构建并安装 Pangolin
git clone https://github.com/stevenlovegrove/Pangolin.git
cd Pangolin
mkdir build && cd build
cmake ..
make -j4
sudo make install
```

### 2. 克隆并构建项目

```bash
# 克隆仓库
git clone https://github.com/xixu-me/RGB-D_SLAM.git
cd RGB-D_SLAM

# 创建构建目录
mkdir build && cd build

# 配置并构建
cmake ..
make -j4
```

### 3. 设置数据集

下载 TUM RGB-D 数据集：

```bash
# 创建数据集目录
mkdir -p dataset

# 下载示例数据集 (freiburg1_xyz)
wget https://vision.in.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz
tar -xzf rgbd_dataset_freiburg1_xyz.tgz -C dataset/

# 生成关联文件
cd dataset/rgbd_dataset_freiburg1_xyz
python ../../associate.py rgb.txt depth.txt > associate.txt
cd ../..
```

## 🚀 使用方法

### 快速开始

```bash
# 使用默认配置运行
./out/bin/slam_app config.yaml

# 或使用自动化脚本
chmod +x compile_and_run.sh
./compile_and_run.sh
```

### 配置设置

编辑 `config.yaml` 来自定义参数：

```yaml
%YAML:1.0

# 数据集路径
dataset_dir: ./dataset/rgbd_dataset_freiburg1_xyz

# 可视化设置
pointSizeCur: 3.15    # 当前帧点大小
pointSizeHis: 2.75    # 历史点大小
waitTime: 1           # 显示延迟 (ms)

# 密集建图 (0=稀疏, 1=密集)
dense: 0
```

### GUI 控制

Pangolin 可视化提供交互式控制：

- **Follow Camera**: 切换相机跟随模式
- **Show Points**: 切换 3D 点云显示
- **Show KeyFrames**: 切换相机轨迹显示
- **Only CurFrames**: 仅显示当前帧或完整轨迹

### 相机控制

- **左键 + 拖拽**: 旋转视图
- **右键 + 拖拽**: 平移视图
- **滚轮**: 缩放
- **中键**: 重置视图

## 🏗️ 系统架构

### 核心组件

```
├── Vo (视觉里程计)
│   ├── 特征提取 (ORB)
│   ├── 特征匹配 (BF Matcher)
│   ├── 位姿估计 (PnP RANSAC)
│   └── 地图点管理
├── Config (配置管理器)
├── Frame (数据结构)
├── MapPoint (3D 点表示)
└── Visualization (Pangolin 线程)
```

### 数据流

1. **帧加载**: 从数据集读取 RGB 和深度图像
2. **特征提取**: 检测 ORB 关键点并计算描述符
3. **特征匹配**: 匹配连续帧之间的特征
4. **位姿估计**: 使用 PnP RANSAC 估计相机运动
5. **地图更新**: 向地图添加新的 3D 点
6. **可视化**: 实时渲染轨迹和点云

### 多线程

- **主线程**: Pangolin 可视化和 GUI
- **工作线程**: 数据处理和 SLAM 计算
- **同步**: 条件变量和互斥锁确保线程安全

## 📊 算法细节

### 特征检测

- **ORB 特征**: 快速且旋转不变
- **每帧 2600 个关键点**，确保鲁棒匹配
- **二进制描述符**，实现高效匹配

### 位姿估计

- **PnP RANSAC**: 从 3D-2D 对应关系进行鲁棒位姿估计
- **相机内参**: TUM 数据集的固定参数
- **深度集成**: 使用深度信息将 2D 特征转换为 3D

### 地图构建

- **稀疏建图**: 基于特征的 3D 重建
- **点云**: 来自 RGB-D 数据的彩色 3D 点
- **内存管理**: 可选择移除点以提高效率

## 🎮 WSL2 GUI 设置

对于 WSL2 用户，GUI 应用程序需要 X 服务器设置：

### 选项 1: Windows 11 与 WSLg（推荐）

- 自动 GUI 支持 - 无需额外设置

### 选项 2: 外部 X 服务器

在 Windows 上安装 X 服务器：

- **VcXsrv**（免费）: <https://sourceforge.net/projects/vcxsrv/>
- **X410**（付费）: Microsoft Store
- **Xming**（免费）: <https://sourceforge.net/projects/xming/>

设置显示变量：

```bash
export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
# 或
export DISPLAY=:0
```

## 📝 文件结构

```
RGB-D_SLAM/
├── CMakeLists.txt          # 构建配置
├── config.yaml             # 运行时配置
├── compile_and_run.sh      # 自动化构建脚本
├── include/                # 头文件
│   ├── common_include.h    # 通用包含和工具
│   ├── config.hpp          # 配置管理
│   ├── DS.h                # 数据结构
│   ├── utils.h             # 工具函数
│   └── Vo.h                # 视觉里程计类
├── src/                    # 源文件
│   ├── utils.cpp           # 工具实现
│   └── Vo.cpp              # 主要 SLAM 实现
├── Main/                   # 应用程序入口点
│   └── main.cpp            # 主函数
├── dataset/                # 数据集目录
│   └── rgbd_dataset_freiburg1_xyz/
└── out/                    # 构建输出
    ├── bin/                # 可执行文件
    └── libs/               # 库文件
```

## 🔧 故障排除

### 常见问题

**OpenGL/Pangolin 错误:**

```bash
# 安装缺失的 OpenGL 库
sudo apt install mesa-utils
# 测试 OpenGL
glxinfo | grep OpenGL
```

**缺失数据集:**

- 确保数据集目录中存在 `associate.txt`
- 检查 `config.yaml` 中的文件路径
- 验证数据集格式符合 TUM RGB-D 规范

**构建错误:**

- 检查 C++23 编译器支持
- 验证所有依赖项已安装
- 清除构建目录并重新构建

### 性能提示

- 减少 `pointSizeCur` 和 `pointSizeHis` 以获得更好性能
- 设置 `dense: 0` 进行稀疏建图（更快）
- 增加 `waitTime` 以减慢处理速度
- 关闭其他应用程序以释放系统资源

## 📚 数据集格式

系统期望 TUM RGB-D 数据集格式：

```
dataset/rgbd_dataset_freiburg1_xyz/
├── rgb/                    # RGB 图像
│   ├── 1305031102.160407.png
│   └── ...
├── depth/                  # 深度图像
│   ├── 1305031102.160407.png
│   └── ...
├── rgb.txt                 # RGB 时间戳
├── depth.txt               # 深度时间戳
├── associate.txt           # 关联的 RGB-深度对
├── groundtruth.txt         # 相机位姿（可选）
└── accelerometer.txt       # IMU 数据（可选）
```

## 🤝 贡献指南

1. Fork 仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 🙏 致谢

- **TUM RGB-D 数据集**: 慕尼黑工业大学提供数据集
- **Pangolin**: Steven Lovegrove 开发的可视化库
- **OpenCV**: 计算机视觉社区提供的综合库
- **Eigen**: 线性代数模板库

## 📞 技术支持

如有问题和疑问：

1. 查看故障排除部分
2. 查阅仓库中的现有问题
3. 创建新的 issue 并提供详细描述

## 许可证

版权所有 &copy; [Xi Xu](https://xi-xu.me)。保留所有权利。

根据 [GPL-3.0](LICENSE) 许可证授权。
