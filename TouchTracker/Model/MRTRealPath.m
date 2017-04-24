//
//  MRTRealPath.m
//  TouchTracker
//
//  Created by mrtanis on 2017/3/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTRealPath.h"

@implementation MRTRealPath

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.pathColor
                  forKey:@"pathColor"];
    [aCoder encodeObject:self.realPath forKey:@"realPath"];
    [aCoder encodeFloat:self.pathWidth forKey:@"pathWidth"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _pathColor = [aDecoder decodeObjectForKey:@"pathColor"];
        _realPath = [aDecoder decodeObjectForKey:@"realPath"];
        _pathWidth = [aDecoder decodeFloatForKey:@"pathWidth"];
    }
    return self;
}

@end
