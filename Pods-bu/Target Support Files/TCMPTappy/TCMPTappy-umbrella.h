#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TCMP-Bridging-Header.h"
#import "TCMP.h"

FOUNDATION_EXPORT double TCMPTappyVersionNumber;
FOUNDATION_EXPORT const unsigned char TCMPTappyVersionString[];

