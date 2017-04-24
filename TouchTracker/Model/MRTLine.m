//
//  MRTLine.m
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTLine.h"

@implementation MRTLine

- (double)angleOfLine
{
    double x = self.end.x - self.begin.x;
    double y = self.end.y - self.begin.y;
    double angle = atan2(x, y) * 180 / M_PI + 180;
    
    return angle;
}

# pragma mark 固化

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.begin forKey:@"begin"];
    [aCoder encodeCGPoint:self.end forKey:@"end"];
    [aCoder encodeFloat:self.lineWidth forKey:@"lineWidth"];
    [aCoder encodeObject:self.lineColor forKey:@"lineColor"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _begin = [aDecoder decodeCGPointForKey:@"begin"];
        _end = [aDecoder decodeCGPointForKey:@"end"];
        _lineWidth = [aDecoder decodeFloatForKey:@"lineWidth"];
        _lineColor = [aDecoder decodeObjectForKey:@"lineColor"];
    }
    return  self;
}

@end
