cmake_minimum_required(VERSION 3.5)
project(MY_SLAM)

# Specify C++ standard
set(CMAKE_CXX_FLAGS "-std=c++23 -g -O0")
set(CMAKE_BUILD_TYPE Debug)


# Find required packages
find_package(OpenCV REQUIRED)
find_package(Pangolin REQUIRED)
find_package(Eigen3 REQUIRED)

# Include header directories
include_directories(
    ${OpenCV_INCLUDE_DIRS}
    ${Pangolin_INCLUDE_DIRS}
    ${EIGEN3_INCLUDE_DIR}
    "./include"
)

set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/out/bin)
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/out/libs)

# Recursively find all .cpp files in src directory and its subdirectories
file(GLOB_RECURSE LIB_SOURCES "src/*.cpp")
file(GLOB_RECURSE MAIN_SOURCES "Main/*.cpp")



add_library(SLAM_LIB_S STATIC ${LIB_SOURCES})
add_library(SLAM_LIB SHARED ${LIB_SOURCES})
# Generate executable
add_executable(slam_app ${MAIN_SOURCES})
# Link libraries
target_link_libraries(SLAM_LIB
    ${OpenCV_LIBS}
    ${Pangolin_LIBRARIES}
    pthread # For multithreading
)
target_link_libraries(SLAM_LIB_S
    ${OpenCV_LIBS}
    ${Pangolin_LIBRARIES}
    pthread # For multithreading
)

target_link_libraries(slam_app SLAM_LIB)
