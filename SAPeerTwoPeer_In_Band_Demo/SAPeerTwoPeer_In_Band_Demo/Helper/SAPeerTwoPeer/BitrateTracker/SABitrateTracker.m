//
//  SABitrateTracker.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SABitrateTracker.h"
#import <QuartzCore/QuartzCore.h>

@implementation SABitrateTracker
{
    CFTimeInterval _prevTime;
    NSInteger _prevByteCount;
}

@synthesize bitrate = _bitrate;

+ (NSString *)bitrateStringForBitrate:(double)bitrate
{
    if (bitrate > 1e6)
    {
        return [NSString stringWithFormat:@"%.2fMbps", bitrate * 1e-6];
    }
    else if (bitrate > 1e3)
    {
        return [NSString stringWithFormat:@"%.0fKbps", bitrate * 1e-3];
    }
    else
    {
        return [NSString stringWithFormat:@"%.0fbps", bitrate];
    }
}

- (NSString *)bitrateString
{
    return [[self class] bitrateStringForBitrate:_bitrate];
}

- (void)updateBitrateWithCurrentByteCount:(NSInteger)byteCount
{
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (_prevTime && (byteCount > _prevByteCount))
    {
        _bitrate = (byteCount - _prevByteCount) * 8 / (currentTime - _prevTime);
    }
    _prevByteCount = byteCount;
    _prevTime = currentTime;
}

@end
