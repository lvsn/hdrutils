/*
 * tiffio.h
 *
 *  Created on: Jan 5, 2009
 *      Author: granados
 */

#ifndef TIFFIO_H_
#define TIFFIO_H_

#include <iostream>
#include <stdexcept>
#include <tiffio.h>
//#include "log.h"

#define TGF(fn, tiff, tag, tagstr, var) if(!TIFFGetFieldDefaulted(tiff, tag, &var)) throw ImageFileNotSupportedException(fn); //else LOGV(var);

using namespace std;
//using namespace base;
//using namespace image;

class ImageFileNotReadableException: public std::runtime_error
{
public:
	ImageFileNotReadableException(const char* filename)
	: std::runtime_error("ImageFileNotFoundException") {}
};

class ImageFileNotWritableException: public std::runtime_error
{
public:
	ImageFileNotWritableException(const char* filename)
	: std::runtime_error("ImageFileNotWritableException") {}
};

class ImageFileNotSupportedException : public std::runtime_error
{
public:
	ImageFileNotSupportedException(const char* filename)
	: std::runtime_error("ImageFileNotSupportedException") {}
};

union TiffBuffer {
    float*  fp;
    uint16* wp;
    uint8*  bp;
    void*   vp;
};

// TODO: merge two TIFFReadImage versions

template <class T>
void TIFFReadImage(T*& sptr0, size_t& ns0, const char* fn, size_t& width0, size_t& height0, size_t& samplesPerPixel0, size_t& bitsPerSample0)
{
	TIFF *tiff = TIFFOpen(fn, "r");
	if (tiff == NULL)
		throw ImageFileNotReadableException(fn);

	uint32 width = 0, height = 0;
	uint16 planarConfig = 0, photometric = 0, orientation = 0, compression = 0;
	uint16 samplesPerPixel = 0, bitsPerSample = 0, sampleFormat = 0;
	uint32 rowsPerStrip = 0;

	TGF(fn, tiff, TIFFTAG_PLANARCONFIG,    "PLANARCONFIG",    planarConfig);
	TGF(fn, tiff, TIFFTAG_PHOTOMETRIC,     "PHOTOMETRIC",     photometric);
	TGF(fn, tiff, TIFFTAG_ORIENTATION,     "ORIENTATION",     orientation);
	TGF(fn, tiff, TIFFTAG_COMPRESSION,     "COMPRESSION",     compression);
	TGF(fn, tiff, TIFFTAG_IMAGELENGTH,     "IMAGELENGTH",     height);
	TGF(fn, tiff, TIFFTAG_IMAGEWIDTH,      "IMAGEWIDTH",      width);
	TGF(fn, tiff, TIFFTAG_SAMPLESPERPIXEL, "SAMPLESPERPIXEL", samplesPerPixel);
	TGF(fn, tiff, TIFFTAG_BITSPERSAMPLE,   "BITSPERSAMPLE",   bitsPerSample);
	TGF(fn, tiff, TIFFTAG_SAMPLEFORMAT,    "SAMPLEFORMAT",    sampleFormat);
	TGF(fn, tiff, TIFFTAG_ROWSPERSTRIP,    "ROWSPERSTRIP",    rowsPerStrip);

	if(!(planarConfig == PLANARCONFIG_CONTIG))
		throw ImageFileNotSupportedException(fn);

	size_t ns = width*height*samplesPerPixel;
	TiffBuffer Ip;
	if(ns0 == ns)
	{
		Ip.vp = sptr0;
	}
	else
	{
		//LOG("reallocating "<<ns<<" bytes, was "<<ns0);
		Ip.vp = new T[ns];
		delete sptr0;
		sptr0 = (T*)Ip.vp;
		ns0 = ns;
	}

	assert(sizeof(float) == 4);
	assert(sizeof(unsigned short) == 2);
	assert(sizeof(unsigned char) == 1);

	uint32 scanLineSize = TIFFScanlineSize(tiff);
	TiffBuffer buf;
	buf.vp = _TIFFmalloc(scanLineSize);
	for(uint32 row=0; row<height; row++)
	{
		TIFFReadScanline(tiff, buf.bp, row);
		for(uint32 col=0; col<width; col++ )
		{
			for(uint16 ch=0; ch<samplesPerPixel; ++ch)
			{
				uint32 inp = col*samplesPerPixel + ch;
				assert(inp < scanLineSize);
				size_t outp = (width*row + col)*samplesPerPixel + ch;
				assert(outp < ns);
				if((sampleFormat == SAMPLEFORMAT_IEEEFP) && (bitsPerSample == 32)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.fp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else if((sampleFormat == SAMPLEFORMAT_UINT) && (bitsPerSample == 16)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.wp[inp];
					else if(typeid(T) == typeid(unsigned short))
						Ip.wp[outp] = buf.wp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else if((sampleFormat == SAMPLEFORMAT_UINT) && (bitsPerSample == 8)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.bp[inp];
					else if(typeid(T) == typeid(unsigned short))
						Ip.wp[outp] = buf.bp[inp];
					else if(typeid(T) == typeid(unsigned char))
						Ip.bp[outp] = buf.bp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else
					throw ImageFileNotSupportedException(fn);
			}
		}
	}
	_TIFFfree(buf.vp);

	width0 = width;
	height0 = height;
	samplesPerPixel0 = samplesPerPixel;
	bitsPerSample0 = bitsPerSample;

	TIFFClose(tiff);
}

template <class T>
T* TIFFReadImage(const char* fn, size_t& width0, size_t& height0, size_t& samplesPerPixel0, size_t& bitsPerSample0)
{
	TIFF *tiff = TIFFOpen(fn, "r");
	if (tiff == NULL)
		throw ImageFileNotReadableException(fn);

	uint32 width = 0, height = 0;
	uint16 planarConfig = 0, photometric = 0, orientation = 0, compression = 0;
	uint16 samplesPerPixel = 0, bitsPerSample = 0, sampleFormat = 0;
	uint32 rowsPerStrip = 0;

	TGF(fn, tiff, TIFFTAG_PLANARCONFIG,    "PLANARCONFIG",    planarConfig);
	TGF(fn, tiff, TIFFTAG_PHOTOMETRIC,     "PHOTOMETRIC",     photometric);
	TGF(fn, tiff, TIFFTAG_ORIENTATION,     "ORIENTATION",     orientation);
	TGF(fn, tiff, TIFFTAG_COMPRESSION,     "COMPRESSION",     compression);
	TGF(fn, tiff, TIFFTAG_IMAGELENGTH,     "IMAGELENGTH",     height);
	TGF(fn, tiff, TIFFTAG_IMAGEWIDTH,      "IMAGEWIDTH",      width);
	TGF(fn, tiff, TIFFTAG_SAMPLESPERPIXEL, "SAMPLESPERPIXEL", samplesPerPixel);
	TGF(fn, tiff, TIFFTAG_BITSPERSAMPLE,   "BITSPERSAMPLE",   bitsPerSample);
	TGF(fn, tiff, TIFFTAG_SAMPLEFORMAT,    "SAMPLEFORMAT",    sampleFormat);
	TGF(fn, tiff, TIFFTAG_ROWSPERSTRIP,    "ROWSPERSTRIP",    rowsPerStrip);

	if(!(planarConfig == PLANARCONFIG_CONTIG))
		throw ImageFileNotSupportedException(fn);

	size_t ns = width*height*samplesPerPixel;
	TiffBuffer Ip;
	Ip.vp = new T[ns];

	assert(sizeof(float) == 4);
	assert(sizeof(unsigned short) == 2);
	assert(sizeof(unsigned char) == 1);

	uint32 scanLineSize = TIFFScanlineSize(tiff);
	TiffBuffer buf;
	buf.vp = _TIFFmalloc(scanLineSize);
	for(uint32 row=0; row<height; row++)
	{
		TIFFReadScanline(tiff, buf.bp, row);
		for(uint32 col=0; col<width; col++ )
		{
			for(uint16 ch=0; ch<samplesPerPixel; ++ch)
			{
				uint32 inp = col*samplesPerPixel + ch;
				assert(inp < scanLineSize);
				size_t outp = (width*row + col)*samplesPerPixel + ch;
				assert(outp < ns);
				if((sampleFormat == SAMPLEFORMAT_IEEEFP) && (bitsPerSample == 32)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.fp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else if((sampleFormat == SAMPLEFORMAT_UINT) && (bitsPerSample == 16)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.wp[inp];
					else if(typeid(T) == typeid(unsigned short))
						Ip.wp[outp] = buf.wp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else if((sampleFormat == SAMPLEFORMAT_UINT) && (bitsPerSample == 8)) {
					if(typeid(T) == typeid(float))
						Ip.fp[outp] = buf.bp[inp];
					else if(typeid(T) == typeid(unsigned short))
						Ip.wp[outp] = buf.bp[inp];
					else if(typeid(T) == typeid(unsigned char))
						Ip.bp[outp] = buf.bp[inp];
					else
						throw invalid_argument("unsupported conversion requested");
				}
				else
					throw ImageFileNotSupportedException(fn);
			}
		}
	}
	_TIFFfree(buf.vp);

	width0 = width;
	height0 = height;
	samplesPerPixel0 = samplesPerPixel;
	bitsPerSample0 = bitsPerSample;

	TIFFClose(tiff);

	return (T*)Ip.vp;
}

template <class T>
void TIFFWriteImage(const char* fn, const T* Ip, size_t width, size_t height, size_t samplesPerPixel, size_t bitsPerSample)
{
	TIFF *tiff = TIFFOpen(fn, "w");
	if(tiff == NULL)
		throw ImageFileNotWritableException(fn);

	TIFFSetField(tiff, TIFFTAG_IMAGEWIDTH, width);
	TIFFSetField(tiff, TIFFTAG_IMAGELENGTH, height);
	TIFFSetField(tiff, TIFFTAG_BITSPERSAMPLE, bitsPerSample);
	TIFFSetField(tiff, TIFFTAG_SAMPLESPERPIXEL, samplesPerPixel);
	TIFFSetField(tiff, TIFFTAG_PLANARCONFIG, PLANARCONFIG_CONTIG);
	TIFFSetField(tiff, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
	TIFFSetField(tiff, TIFFTAG_COMPRESSION, COMPRESSION_NONE);
	TIFFSetField(tiff, TIFFTAG_ROWSPERSTRIP, 1);

	assert(sizeof(float) == 4);
	assert(sizeof(unsigned short) == 2);
	assert(sizeof(unsigned char) == 1);

	if(typeid(T) == typeid(float))
		TIFFSetField(tiff, TIFFTAG_SAMPLEFORMAT, SAMPLEFORMAT_IEEEFP);
	else if(typeid(T) == typeid(unsigned char) || typeid(T) == typeid(unsigned short))
		TIFFSetField(tiff, TIFFTAG_SAMPLEFORMAT, SAMPLEFORMAT_UINT);
	else
		throw ImageFileNotSupportedException(fn);

	if(samplesPerPixel == 1)
		TIFFSetField(tiff, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_MINISBLACK);
	else if(samplesPerPixel == 3)
		TIFFSetField(tiff, TIFFTAG_PHOTOMETRIC, PHOTOMETRIC_RGB);
	else
		throw ImageFileNotSupportedException(fn);

	const size_t row_size = width*samplesPerPixel;
	for(tstrip_t row=0; row<height; ++row) {
		tdata_t buf = (tdata_t)(Ip + row * row_size);
		if(TIFFWriteScanline(tiff, buf, row, 0) < 0)
			throw ImageFileNotWritableException(fn);
	}

	TIFFClose(tiff);
}

#endif /* TIFFIO_H_ */
