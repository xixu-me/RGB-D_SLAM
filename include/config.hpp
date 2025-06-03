#pragma once
#include <common_include.h>

class Config {
public:
	// Create FileStorage object and open YAML file
	cv::FileStorage fs;
	double pointSizeCur;
	double pointSizeHis;
	string DATASET_ROOT;
	int WK_TIME;
	bool isDense;
	Config(const string &fileName) : fs(fileName, cv::FileStorage::READ) {
		fs["dataset_dir"] >> DATASET_ROOT;
		fs["waitTime"] >> WK_TIME;
		fs["pointSizeCur"] >> pointSizeCur;
		fs["pointSizeHis"] >> pointSizeHis;
		fs["dense"] >> isDense;
		println("Read data: {}, dense={}", DATASET_ROOT, isDense);
	}
	~Config() {
		fs.release();
	}
};