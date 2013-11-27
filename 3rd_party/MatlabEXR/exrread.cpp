/*
 * MATLAB MEX function for reading EXR images.
 * 
 * Only supports EXR images with half-precision floating-point data.
 *
 */

#include "ImathBox.h"
#include "ImfRgba.h"
#include "ImfInputFile.h"
#include "ImfRgbaFile.h"
#include "ImfArray.h"
#include "ImfChannelList.h"
#include "ImfPixelType.h"
#include "Iex.h"

#include "mex.h" 

using namespace Imf;
using namespace Imath;
using namespace Iex;

/*
 * Check inputs
 * Only one input argument that is a string (row vector of chars)
 * one or two output arguments
 * 
 * These checks were copied from the MATLAB example file revord.c
 */
void checkInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	if (nrhs > 2)
		mexErrMsgTxt("Incorrect number of input arguments.");

	if (nlhs < 1 || nlhs > 2)
		mexErrMsgTxt("Incorrect number of output arguments.");

	if (mxIsChar(prhs[0]) != 1)
		mexErrMsgTxt("Input must be a string.");

	if (mxGetM(prhs[0]) != 1)
		mexErrMsgTxt("Input must be a row vector.");

	return;
}

/*
 * Check that the image is one of the supported formats (1-4 channels of
 * half-precision floating-point data).
 */
int numChannels(const RgbaInputFile &file) {

	const ChannelList &ch = file.header().channels();
	int nchannels = 0;
	for (ChannelList::ConstIterator i = ch.begin(); i != ch.end(); ++i) {
		const Channel &channel = i.channel(); 
		PixelType type = channel.type;

		if (type == HALF) 
            ++nchannels;
	}

	if (nchannels > 4) {
		mexWarnMsgTxt("Image has more than 4 channels.");
		nchannels = 4;
	}

	return nchannels;
}

int numChannels32(const RgbaInputFile &file) {

	const ChannelList &ch = file.header().channels();
	int nchannels = 0;
	for (ChannelList::ConstIterator i = ch.begin(); i != ch.end(); ++i) {
		const Channel &channel = i.channel(); 
		PixelType type = channel.type;

		if (type == FLOAT) 
		++nchannels;
	}

	if (nchannels > 4) {
		mexWarnMsgTxt("Image has more than 4 channels.");
		nchannels = 4;
	}

	return nchannels;
}

int bitsForLayer(const RgbaInputFile &file, const char layerName[]) {

	const ChannelList &ch = file.header().channels();
	int nchannels = 0;
	for (ChannelList::ConstIterator i = ch.begin(); i != ch.end(); ++i) {
		const Channel &channel = i.channel(); 
		PixelType type = channel.type;
        
        std::string n = i.name();
        if (n==layerName) {
            if (type == FLOAT)
                return 32;
            else if (type == HALF)
                return 16;
        }
	}
    return 0;
}

/*
 * Read an EXR file.
 * Code follows examples from ReadingAndWritingImageFiles.pdf, found
 * here:
 * http://www.openexr.com/ReadingAndWritingImageFiles.pdf
 *
 */
typedef struct RGBA_FLOAT {
    float r;
    float g;
    float b;
    float a;
};
    
void readRgbaFloat (const char fileName[],
        Array2D<RGBA_FLOAT> &rgbaPixels,
        int &width, int &height) 
{
    InputFile file (fileName);
    Box2i dw = file.header().dataWindow();
    width = dw.max.x - dw.min.x + 1;
    height = dw.max.y - dw.min.y + 1;
    rgbaPixels.resizeErase (height, width);
    FrameBuffer frameBuffer;
    frameBuffer.insert ("R", // name
            Slice (FLOAT, // type
            (char *) (&rgbaPixels[0][0].r - // base
            dw.min.x -
            dw.min.y * width),
            sizeof (rgbaPixels[0][0]) * 1, // xStride
            sizeof (rgbaPixels[0][0]) * width,// yStride
            1, 1, // x/y sampling
            0.0)); // fillValue
    frameBuffer.insert ("G", // name
            Slice (FLOAT, // type
            (char *) (&rgbaPixels[0][0].g - // base
            dw.min.x -
            dw.min.y * width),
            sizeof (rgbaPixels[0][0]) * 1, // xStride
            sizeof (rgbaPixels[0][0]) * width,// yStride
            1, 1, // x/y sampling
            0.0)); // fillValue
    frameBuffer.insert ("B", // name
            Slice (FLOAT, // type
            (char *) (&rgbaPixels[0][0].b - // base
            dw.min.x -
            dw.min.y * width),
            sizeof (rgbaPixels[0][0]) * 1, // xStride
            sizeof (rgbaPixels[0][0]) * width,// yStride
            1, 1, // x/y sampling
            0.0)); // fillValue
    file.setFrameBuffer (frameBuffer);
    file.readPixels (dw.min.y, dw.max.y);
}

void readZFloat (const char fileName[],
        const char layerName[],
        Array2D<float> &zPixels,
        int &width, int &height) 
{
    InputFile file (fileName);
    Box2i dw = file.header().dataWindow();
    width = dw.max.x - dw.min.x + 1;
    height = dw.max.y - dw.min.y + 1;
    zPixels.resizeErase (height, width);
    FrameBuffer frameBuffer;
    frameBuffer.insert (layerName, // name
            Slice (FLOAT, // type
            (char *) (&zPixels[0][0] - // base
            dw.min.x -
            dw.min.y * width),
            sizeof (zPixels[0][0]) * 1, // xStride
            sizeof (zPixels[0][0]) * width,// yStride
            1, 1, // x/y sampling
            0.0)); // fillValue
    file.setFrameBuffer (frameBuffer);
    file.readPixels (dw.min.y, dw.max.y);
}

void readZHalf (const char fileName[],
        const char layerName[],
        Array2D<half> &zPixels,
        int &width, int &height) 
{
    InputFile file (fileName);
    Box2i dw = file.header().dataWindow();
    width = dw.max.x - dw.min.x + 1;
    height = dw.max.y - dw.min.y + 1;
    zPixels.resizeErase (height, width);
    FrameBuffer frameBuffer;
    frameBuffer.insert (layerName, // name
            Slice (HALF, // type
            (char *) (&zPixels[0][0] - // base
            dw.min.x -
            dw.min.y * width),
            sizeof (zPixels[0][0]) * 1, // xStride
            sizeof (zPixels[0][0]) * width,// yStride
            1, 1, // x/y sampling
            0.0)); // fillValue
    file.setFrameBuffer (frameBuffer);
    file.readPixels (dw.min.y, dw.max.y);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    checkInputs(nlhs, plhs, nrhs, prhs);
    char *filename = mxArrayToString(prhs[0]);
    
    try {
        RgbaInputFile file(filename);
        
        // Get the image type
        int nchannels = numChannels(file);
        int nchannels32 = numChannels32(file);
        
        if (nrhs>1) {
            // Named single layer
            char *layerName = mxArrayToString(prhs[1]);
            int nBits = bitsForLayer( file, layerName );
            printf("Reading a %d-bit layer %s\n", nBits, layerName);
            if (nBits==32) {
                Array2D<float> zPixels;
                
                int xdim, ydim;
                readZFloat(filename,
                        layerName,
                        zPixels,
                        xdim, ydim);
                
                int dims[3];
                int sz = xdim*ydim;
                dims[0] = ydim;
                dims[1] = xdim;
                dims[2] = 1;
//             printf("%d %d\n", xdim, ydim);
                if (nlhs == 1) {
                    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                    double *img = mxGetPr(plhs[0]);
                    
                    for (int i = 0; i < ydim; ++i) {
                        for (int j = 0; j < xdim; ++j) {
                            int k = j*ydim + i;
                            
                            img[k] = zPixels[i][j];
                        }
                    }
                } else {
                    mexWarnMsgTxt("Unsupported image type (only RGB for 32-bit floating point).");
                }
        } else if (nBits==16) {
                Array2D<half> zPixels;
                
                int xdim, ydim;
                readZHalf(filename,
                        layerName,
                        zPixels,
                        xdim, ydim);
                
                int dims[3];
                int sz = xdim*ydim;
                dims[0] = ydim;
                dims[1] = xdim;
                dims[2] = 1;
//             printf("%d %d\n", xdim, ydim);
                if (nlhs == 1) {
                    plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                    double *img = mxGetPr(plhs[0]);
                    
                    for (int i = 0; i < ydim; ++i) {
                        for (int j = 0; j < xdim; ++j) {
                            int k = j*ydim + i;
                            
                            img[k] = zPixels[i][j];
                        }
                    }
                } else {
                    mexWarnMsgTxt("Unsupported image type (only RGB for 32-bit floating point).");
                }                
        }
        } else if (nchannels == 0 && nchannels32>2) {
//             mexWarnMsgTxt("Reading 32-bit floating point image.");
            Array2D<RGBA_FLOAT> rgbaPixels;
            
            int xdim, ydim;
            readRgbaFloat(filename,
                    rgbaPixels,
                    xdim, ydim);
            
            int dims[3];
            int sz = xdim*ydim;
            dims[0] = ydim;
            dims[1] = xdim;
            dims[2] = 3;
            
//             printf("%d %d\n", xdim, ydim);
            if (nlhs == 1) {
                
                plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *img = mxGetPr(plhs[0]);
                
                for (int i = 0; i < ydim; ++i) {
                    for (int j = 0; j < xdim; ++j) {
                        int k = j*ydim + i;
                        
                        img[k]      = rgbaPixels[i][j].r;
                        img[sz+k]   = rgbaPixels[i][j].g;
                        img[2*sz+k] = rgbaPixels[i][j].b;
                    }
                }
            } else {
                mexWarnMsgTxt("Unsupported image type (only RGB for 32-bit floating point).");
            }
		} else if (nchannels32==1) {
            Array2D<float> zPixels;
            
            printf("Reading a 32-bit Z layer only.\n");

            int xdim, ydim;
            readZFloat(filename,
                    "Z",
                    zPixels,
                    xdim, ydim);
            
            int dims[3];
            int sz = xdim*ydim;
            dims[0] = ydim;
            dims[1] = xdim;
            dims[2] = 1;
//             printf("%d %d\n", xdim, ydim);
            if (nlhs == 1) {
                plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *img = mxGetPr(plhs[0]);
                
                for (int i = 0; i < ydim; ++i) {
                    for (int j = 0; j < xdim; ++j) {
                        int k = j*ydim + i;
                        
                        img[k] = zPixels[i][j];
                    }
                }
            } else {
                mexWarnMsgTxt("Unsupported image type (only RGB for 32-bit floating point).");
            }
        } else {
            Box2i dw = file.dataWindow();
            int xdim  = dw.max.x - dw.min.x + 1;
            int ydim = dw.max.y - dw.min.y + 1;
            
            Array2D<Rgba> px(ydim,xdim);
            
            file.setFrameBuffer(&px[0][0]-dw.min.x-dw.min.y*xdim, 1, xdim);
            file.readPixels(dw.min.y, dw.max.y);
            
            int dims[3];
            int sz = xdim*ydim;
            dims[0] = ydim;
            dims[1] = xdim;
            dims[2] = 1;
            
            // Initialize mask if call has 2 arguments on left-hand side,
            // but the image does not have a mask
            if (nlhs == 2 && (nchannels % 2) == 1) {
                plhs[1] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *msk = mxGetPr(plhs[1]);
                
                for (int i = 0; i < sz; ++i) {
                    msk[i] = 1.0;
                }
            }
            
            dims[2] = 3;
            if (nchannels < 3) {
                sz      = 0;
                dims[2] = 1;
            }
            
            if (nlhs == 1) {
                
                plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *img = mxGetPr(plhs[0]);
                
                for (int i = 0; i < ydim; ++i) {
                    for (int j = 0; j < xdim; ++j) {
                        int k = j*ydim + i;
                        
                        img[k]      = px[i][j].r;
                        img[sz+k]   = px[i][j].g;
                        img[2*sz+k] = px[i][j].b;
                    }
                }
                
                /*
                 * Floating point image and alpha channel
                 */
            } else {
                plhs[0] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *img = mxGetPr(plhs[0]);
                
                dims[2] = 1;
                plhs[1] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
                double *msk = mxGetPr(plhs[1]);
                
                for (int i = 0; i < ydim; ++i) {
                    for (int j = 0; j < xdim; ++j) {
                        int k = j*ydim + i;
                        
                        img[k]      = px[i][j].r;
                        img[sz+k]   = px[i][j].g;
                        img[2*sz+k] = px[i][j].b;
                        msk[k]      = px[i][j].a;
                    }
                }
            }
        }
	} catch (const std::exception &exc) {
		mexErrMsgTxt(exc.what());
	}
    mxFree(filename);

	return;
} 


