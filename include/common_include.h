#pragma once

#include <bits/stdc++.h>
#include <format>

#include <condition_variable>

#include <pangolin/pangolin.h>
#include <opencv2/opencv.hpp>
#include <Eigen/Core>
#include <Eigen/Geometry>
#include <opencv2/core/eigen.hpp>

// Simple println implementation using std::vformat
template <typename... Args>
void println(const std::string &fmt, Args &&...args) {
	try {
		std::string formatted = std::vformat(fmt, std::make_format_args(args...));
		std::cout << formatted << std::endl;
	}
	catch (...) {
		std::cout << fmt << std::endl;
	}
}

// Overload for no arguments
inline void println(const std::string &msg) {
	std::cout << msg << std::endl;
}

// Display window name constant
inline constexpr auto WIN_NAME = "SLAM RGB-D Image";

using namespace std;
