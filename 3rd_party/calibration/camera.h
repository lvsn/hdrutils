#ifndef CAMERA_H
#define CAMERA_H

#include <iostream>

#define CC 3

struct Camera {
  float g[CC];
  ImageFloat32rgb aj;
  float Rmu[CC];
  float Rvar[CC];
  unsigned short vsat[CC];
  string ffmeanfn;
  string ajfn; 
};

std::ostream& operator<<(std::ostream& os, const Camera& cam) {
	for(size_t c=0; c<CC; ++c) {
		os<<cam.g[c]<<endl;
		os<<cam.Rmu[c]<<endl;
		os<<cam.Rvar[c]<<endl;
		os<<cam.vsat[c]<<endl;
	}
	os<<cam.ffmeanfn<<endl;
	os<<cam.ajfn;
	return os;
}

std::istream& operator>>(std::istream& is, Camera& cam) {
	for(size_t c=0; c<CC; ++c) {
		is>>cam.g[c];
		is>>cam.Rmu[c];
		is>>cam.Rvar[c];
		is>>cam.vsat[c];
	}
	is>>cam.ffmeanfn;
	is>>cam.ajfn;
	return is;
}

#endif
