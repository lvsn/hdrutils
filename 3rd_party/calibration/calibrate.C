// This code calibrates the parameters of a digital camera sensor 
// (gain, readout noise mean and variance, saturation point, and 
// photo-response non-uniformity) according to the procedures 
// described in the paper:
//
// Optimal HDR reconstruction with linear digital cameras
//  M. Granados, B. Ajdin, M. Wand, C. Theobalt, H.-P. Seidel, H. P. A. Lensch
//  In Proc. IEEE Conf. Comp. Vis. Pat. Rec. (CVPR), 
//  June 13-18, 2010, San Francisco, USA
//
// Author: Miguel Granados. 2011

// for converting raw files to 16bit tiff please use:
// dcraw -v -c -D -h -4 -T filename.cr2 > filename.tif
//   tested with dcraw 9.10

#include "image.h"
#include "ioutils.h"
#include "camera.h"
#include "log.h"
#include <fstream>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

const string ffmeanfn("ffmean.tif");
const string ajfn = "aj.tif";

void estimate_readoutparams(string bf, Camera& cam) {
	LOG("reading "<<bf);
	ImageUint16rgb img(bf.c_str());
	for(size_t c=0; c<CC; ++c) {
		// compute readout mean
		double sum = 0;
		for(int j=0; j<img.getPixels(); ++j)
			sum += img(j, c);
		cam.Rmu[c] = sum/img.getPixels();
		LOGV(cam.Rmu[c]);
		// compute readout variance
		sum = 0;
		for(int j=0; j<img.getPixels(); ++j)
			sum += (img(j, c) - cam.Rmu[c])*(img(j, c) - cam.Rmu[c]);
		cam.Rvar[c] = sum/(img.getPixels()-1);
		LOGV(cam.Rvar[c]);
	}
}

void estimate_saturationvalue(string sf, Camera& cam) {
	LOG("reading "<<sf);
	ImageUint16rgb img(sf.c_str());
	for(size_t c=0; c<CC; ++c) {
		// compute saturation frame mean
		unsigned short vmin = img(0, c), vmax = img(0, c);
		double sum = 0;
		for(int j=0; j<img.getPixels(); ++j) {
			sum += img(j, c);
			vmin = min(vmin, img(j, c));
			vmax = max(vmax, img(j, c));
		}
		LOGV(vmin);
		LOGV(vmax);
		double sfmean = sum/img.getPixels();
		LOGV(sfmean);
		// compute saturation frame variance
		sum = 0;
		for(int j=0; j<img.getPixels(); ++j)
			sum += (img(j, c) - sfmean)*(img(j, c) - sfmean);
		double sfvar = sum/(img.getPixels()-1);
		LOGV(sfvar);
		cam.vsat[c] = (unsigned int)(sfmean - 6*sqrt(sfvar));
		LOGV(cam.vsat[c]);
	}
}

template <class Sit>
void estimate_gainperpixel(Sit begin, Sit end, Sit dbegin, Sit dend, Camera& cam) {
	ImageUint16rgb img(begin->c_str()), dimg(dbegin->c_str());
	// compute flat field frame mean
	ImageFloat32rgb ffmean(img.getWidth(), img.getHeight(), 0.f);
        struct stat stat_str;
        if(stat(ffmeanfn.c_str(), &stat_str) == 0) { // file exists
		LOG("reading "<<ffmeanfn);
		ffmean.read(ffmeanfn);
	}
	else {
		size_t ns = 0;
		for(Sit sit=begin, dsit=dbegin; sit!=end; ++sit, ++dsit, ++ns) {
			LOG("reading "<<*sit);
			img.read(*sit);
			LOG("reading "<<*dsit);
			dimg.read(*dsit);
			for(size_t c=0; c<CC; ++c) {
				for(int j=0; j<img.getPixels(); ++j)
					ffmean(j, c) += img(j, c) - dimg(j, c);
			}
		}
		for(size_t c=0; c<CC; ++c) {
			for(int j=0; j<img.getPixels(); ++j)
				ffmean(j, c) /= ns;
		}
		LOG("writting "<<ffmeanfn);
		ffmean.writeTiff(ffmeanfn);
	}
  
	for(size_t c=0; c<CC; ++c) {
		double ffmeanmean = 0;
		for(int j=0; j<ffmean.getPixels(); ++j)
			ffmeanmean += ffmean(j, c);
		ffmeanmean /= ffmean.getPixels();
		for(int j=0; j<ffmean.getPixels(); ++j)
			ffmean(j, c) /= ffmeanmean;
	}

	LOG("writting "<<ajfn);
	ffmean.writeTiff(ajfn.c_str());
}

template <class Sit>
void estimate_cameragain(Sit ffbegin, Sit ffend, Camera& cam) {
	double summeanff[] = {0, 0, 0};
	double summeandiff[] = {0, 0, 0};
	double sumvardiff[] = {0, 0, 0};
	size_t nff = 0;

	Sit ffit0 = ffbegin;
	Sit ffit1 = ffbegin+1;
	LOG("reading "<<*ffit0);
	ImageUint16rgb ff0(ffit0->c_str());
	ImageUint16rgb ff1(ffit1->c_str());
	while(ffit0 != ffend) {

		// compute frame spatial average
		double meanff[] = {0, 0, 0};
		for(int j=0; j<ff0.getPixels(); ++j) {
			for(size_t c=0; c<CC; ++c) {
				meanff[c] += ff0(j, c);
			}
		}
		for(size_t c=0; c<CC; ++c) {
			meanff[c] /= ff0.getPixels();
			LOGV(meanff[c]);
		}

		// compute frame difference spatial average
		double meandiff[] = {0, 0, 0};
		for(int j=0; j<ff0.getPixels(); ++j) {
			for(size_t c=0; c<CC; ++c) {
				double d = ff0(j, c) - ff1(j, c);
				meandiff[c] += d;
			}
		}
		for(size_t c=0; c<CC; ++c) {
			meandiff[c] /= ff0.getPixels();
			LOGV(meandiff[c]);
		}

		// compute frame difference spatial variance
		double vardiff[] = {0, 0, 0};
		for(int j=0; j<ff0.getPixels(); ++j) {
			for(size_t c=0; c<CC; ++c) {
				double d = ff0(j, c) - ff1(j, c);
				vardiff[c] += (d-meandiff[c])*(d-meandiff[c]);
			}
		}
		for(size_t c=0; c<CC; ++c) {
			if(c == 1)
				vardiff[c] *= 2;
			vardiff[c] /= (ff0.getPixels() - 1);
			LOGV(vardiff[c]);
		}

		for(size_t c=0; c<CC; ++c) {
			summeanff[c] += meanff[c];
			summeandiff[c] += meandiff[c];
			sumvardiff[c] += vardiff[c];
		}
		
		++ffit0;
		++ffit1;
		if(ffit1 == ffend)
			ffit1 = ffbegin;
		if(ffit0 != ffend) {
			LOG("reading "<<*ffit1);
			ff0 = ff1;
			ff1 = ImageUint16rgb(*ffit1);
			++nff;
		}
	}

	for(size_t c=0; c<CC; ++c) {
		summeanff[c] /= nff;
		summeandiff[c] /= nff;
		sumvardiff[c] /= nff;
		LOGV(summeanff[c]);
		LOGV(summeandiff[c]);
		LOGV(sumvardiff[c]);
	}
	
	for(size_t c=0; c<CC; ++c) {
		LOGV(cam.Rvar[c]);
		LOGV(cam.Rmu[c]);
		cam.g[c] = (0.5*sumvardiff[c] - cam.Rvar[c]) / (summeanff[c] - cam.Rmu[c]);
	}
}

// usage: calibrate bfdir sfdir ffdir
int main(int argc, char **argv) {
	if(argc != 5) {
	  cerr<<"usage: calibrate bfdir sfdir ffdir ffdfdir"<<endl;
	  cerr<<endl;
	  cerr<<"       bfdir: directory with bias frame"<<endl;
	  cerr<<"       sfdir: directory with saturation frame"<<endl;
	  cerr<<"       ffdir: directory with flat field frames"<<endl;
	  cerr<<"       ffdfdir: directory with flat field dark frames"<<endl;
	  exit(1);
	}
	const string imgext(".tif");
	vector<string> bf, sf, ff, ffdf;
	bf = ls(argv[1], imgext);
	LOGV(bf.size());
	sf = ls(argv[2], imgext);
	LOGV(sf.size());
	ff = ls(argv[3], imgext);
	LOGV(ff.size());
	ffdf = ls(argv[4], imgext);
	LOGV(ff.size());

	Camera cam;
	if(bf.size() == 0)
		exit(1);
	estimate_readoutparams(bf[0], cam);
	
	if(sf.size() == 0)
		exit(1);
	estimate_saturationvalue(sf[0], cam);

	if(ff.size() < 2)
		exit(1);
	estimate_gainperpixel(ff.begin(), ff.end(), ffdf.begin(), ffdf.end(), cam);

	estimate_cameragain(ff.begin(), ff.end(), cam);

	cam.ffmeanfn = ffmeanfn;
	cam.ajfn = ajfn;

	for(size_t c=0; c<CC; ++c) {
		LOGV(cam.g[c]);
		LOGV(cam.Rmu[c]);
		LOGV(cam.Rvar[c]);
		LOGV(cam.vsat[c]);
		LOGV(cam.ffmeanfn);
		LOGV(cam.ajfn);
	}
	
	std::ofstream camf("cam.conf");
	camf<<cam<<endl;
	camf.close();
  
	return 0;
}
