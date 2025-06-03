#pragma once

#include <common_include.h>
#include <DS.h>
#include <config.hpp>
class Vo {
public:
	~Vo() = default;
	Vo() = default;
	unique_ptr<Config> cfgPtr;
	Frame preFrame;			  // Previous frame
	bool hasPreFrame = false; // Whether there is a previous frame

	vector<MapPoint> mapPoints; // 3D points
	decltype(mapPoints)::iterator currMapPointsIter;
	Eigen::Isometry3d cumulaPos = Eigen::Isometry3d::Identity(); // Cumulative pose
	vector<Eigen::Isometry3d> cameraPoses;						 // Container for saving camera poses
	cv::Mat K;													 // Camera intrinsic parameters

	// Ensure thread synchronization
	atomic<int> atmVersion;
	condition_variable conVar;
	mutex mtx;
	atomic<bool> isRun;
	bool followCamera = true;
	bool showPoints = true;
	bool showKeyframes = true;
	bool onlyshowCurframes = true;
	unique_ptr<pangolin::Var<bool>> guiFollowCameraPtr;
	unique_ptr<pangolin::Var<bool>> guiShowKeyPointsPtr;
	unique_ptr<pangolin::Var<bool>> guiShowKeyFramesPtr;
	unique_ptr<pangolin::Var<bool>> guiOnlyShowCurFramesPtr;
	Files rgbData, depthData;

	unique_ptr<pangolin::OpenGlRenderState> sCamera;
	pangolin::View* dCamera;

	// Initialize
	void init(const string &configFileList);
	// Entry point
	void applictionStart();
	// Computation thread
	void processData();
	// Visualization thread (main thread)
	void runPangoLin();

	// Extract features from one frame
	void extractFeatures(Frame &frame);
	// Match features between consecutive frames
	vector<cv::DMatch> matchFeatures(const Frame &fPrev, const Frame &fCur);
	
	// Estimate camera pose
	Eigen::Isometry3d estimatePose(
		const Frame &framePrev, const Frame &frame2,
		const vector<cv::DMatch> &matches);

	// Add map points
	void addFrame(const Frame &frame);

	// Draw camera position
	void drawKeyFrame(const Eigen::Vector3d &pos, const array<double, 3> &colors, double size = 0.1);
};
