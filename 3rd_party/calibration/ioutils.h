#ifndef IO_UTILS_H
#define IO_UTILS_H

#include <vector>
#include <sys/types.h>
#include <dirent.h>

using namespace std;

vector<string> ls(string base, string wildcard) {
  DIR *dp  = opendir(base.c_str());
  struct dirent *ep;
  vector<string> files;
  if(dp != NULL) {
    while((ep = readdir(dp))) {
      string fn(ep->d_name);
      if(fn.find(wildcard, fn.size()-wildcard.size()-1) < fn.size())
	 files.push_back(base + "/" + fn);
    }
    closedir(dp);
  }
  return files;
}

#endif // IO_UTILS_H
