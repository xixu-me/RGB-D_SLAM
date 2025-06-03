#include <common_include.h>
#include <DS.h>
#include <utils.h>

// Read association file
AssociateList readAssociationFile(const string &fileName) {
	println("Reading file: {}", fileName);
	Files dRgb, dDepth;
	ifstream file(fileName);
	if (!file.is_open()) {
		println("Cannot open file");
		exit(-1);
	}
	string line;
	while (getline(file, line)) {
		istringstream ss(line);
		FileInfo rgb, _depth;
		ss >> rgb.timeStamp >> rgb.fileName >> _depth.timeStamp >> _depth.fileName;
		dRgb.emplace_back(move(rgb));
		dDepth.emplace_back(move(_depth));
	}
	return { dRgb, dDepth };
}
