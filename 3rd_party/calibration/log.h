/*
 * log.h
 *
 * Author: Miguel Granados, MPI Informatik
 *
 * Version: $Id: log.h 1233 2011-03-24 10:24:58Z granados $
 *
 */

#ifndef __LOG_H__
#define __LOG_H__

#include <iostream>

#define LOGT(stream,str,endchar) stream<<__FUNCTION__<<": "<<str<<endchar

#define LOGR(str)          LOGT(std::cerr, str, '\r')
#define LOG(str)           LOGT(std::cerr, str, '\n')
#define OUT(str)          {LOGT(std::cout, str, '\n');LOG(str);}

#define LOGVR(v)           LOGR((#v)<<"="<<v)
#define LOGV(v)            LOG ((#v)<<"="<<v)
#define OUTV(v)            OUT ((#v)<<"="<<v)

#define LOGV2(v1,v2)       LOG ((#v1)<<"="<<v1<<", "<<(#v2)<<"="<<v2)
#define OUTV2(v1,v2)       OUT ((#v1)<<"="<<v1<<", "<<(#v2)<<"="<<v2)

#define LOGV3(v1,v2,v3)    std::cerr<<__FUNCTION__<<": "<<(#v1)<<"="<<v1<<", "<<(#v2)<<"="<<v2<<", "<<(#v3)<<"="<<v3<<"\n"
#define LOGV4(v1,v2,v3,v4) std::cerr<<__FUNCTION__<<": "<<(#v1)<<"="<<v1<<", "<<(#v2)<<"="<<v2<<", "<<(#v3)<<"="<<v3<<", "<<(#v4)<<"="<<v4<<"\n"
#define LOGV5(v1,v2,v3,v4,v5) std::cerr<<__FUNCTION__<<": "<<(#v1)<<"="<<v1<<", "<<(#v2)<<"="<<v2<<", "<<(#v3)<<"="<<v3<<", "<<(#v4)<<"="<<v4<<", "<<(#v5)<<"="<<v5<<"\n"

#define WARNING(str)               std::cerr<<__FUNCTION__<<": WARNING: "<<str<<"\n"
#define ERROR(str)               { std::cerr<<__FUNCTION__<<  ": ERROR: "<<str<<"\n"; exit(1); }

#define ASSERT(expr) if(!(expr)) { std::cerr<<__FILE__<<":"<<__LINE__<<":"<<__FUNCTION__<<": assertion failed: "<<(#expr)<<"\n"; exit(1); }
#define ASSERT_IFTHEN(a, b) ASSERT(!(a) || (b));

#define warning(test) if(!(test)) { WARNING("!("<<(#test)<<")"); }

#endif /* __LOG_H__ */
