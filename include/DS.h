
#pragma once

#include <common_include.h>

// Data structure definitions
struct Frame {
	cv::Mat rgbImgCv;
	cv::Mat depthImgCv;
	std::vector<cv::KeyPoint> keypoints;
	cv::Mat descriptors;
	Eigen::Isometry3d pose = Eigen::Isometry3d::Identity();
};

struct MapPoint {
	Eigen::Vector3d position;
	cv::Mat descriptor;
};

struct FileInfo {
	double timeStamp;
	string fileName;
};

using Files = vector<FileInfo>;
using AssociateList = tuple<Files, Files>;