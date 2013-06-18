#ifndef IMAGE_H
#define IMAGE_H

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <string>
#include <stdexcept>
#include <typeinfo>
#include "log.h"
#include "TiffIO.h"

template <typename T, int N>
class ImageBase
{
  typedef cv::Vec<T, N> V;
  typedef cv::DataType<V> DT;

public:
  ImageBase()
    {
    }

 ImageBase(int width, int height, T initvalue)
   {
     V v;
     for(int i=0; i<N; ++i)
       v[i] = initvalue;
     M = cv::Mat_<V>(height, width, v);
     //LOGV2(M.depth(), M.channels());
    }

  ImageBase(const std::string& fn) 
    {
      read(fn);
    }

  ImageBase& operator=(const ImageBase& a)
    {
      M = a.M;
      return *this;
    }

  void read(const std::string& fn)
  {
    size_t width, height, spp, bps;
    T* ptr = TIFFReadImage<T>(fn.c_str(), width, height, spp, bps);
    M = cv::Mat_<V>(height, width, (V*)ptr);
    //LOGV4(width, height, spp, bps);
  }

  void writeTiff(const std::string& fn)
  {
    //LOGV4(N, sizeof(T)*8, getWidth(), getHeight());
    TIFFWriteImage(fn.c_str(), (T*)M.ptr(), getWidth(), getHeight(), N, sizeof(T)*8);
  }
  
  int getPixels() const
  {
    return M.rows*M.cols;
  }

  int getWidth() const
  {
    return M.cols;
  }

  int getHeight() const
  {
    return M.rows;
  }
  
  const T& operator()(int p, int c) const
  {
    const int y = p/M.rows, x = p%M.rows;
    return M(x, y)[c];
  }

  T& operator()(int p, int c)
  {
    const int y = p/M.rows, x = p%M.rows;
    return M(x, y)[c];
  }

 protected:
  cv::Mat_<V> M;

};

typedef ImageBase<unsigned short, 3> ImageUint16rgb;
typedef ImageBase<float, 3> ImageFloat32rgb;

#endif // IMAGE_H
