//
//  MRTCircle.m
//  TouchTracker
//
//  Created by mrtanis on 2017/2/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTCircle.h"

@implementation MRTCircle

- (instancetype)initWithBoundaryPoints:(NSArray *)points
{
    self = [super init];
    if (self) {
        if (points.count == 2) {
            CGPoint point1 = [points[0] CGPointValue];
            CGPoint point2 = [points[1] CGPointValue];
            _center.x = fabs(point1.x - point2.x) / 2 + MIN(point1.x, point2.x);
            _center.y = fabs(point1.y - point2.y) / 2 + MIN(point1.y, point2.y);
            _radius = hypot(fabs(point1.x - point2.x), fabs(point1.y - point2.y)) / 2;
            _bounds = CGRectMake(_center.x - _radius, _center.y - _radius, _radius * 2, _radius *2);
        } else {
            _center = CGPointZero;
            _radius = 0;
            _bounds = CGRectZero;
        }
        
    }
    self.points = [points mutableCopy];
    return self;
}

- (instancetype)init
{
    return [self initWithBoundaryPoints:nil];
}

#pragma mark 固化

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.center forKey:@"center"];
    [aCoder encodeFloat:self.radius forKey:@"radius"];
    [aCoder encodeCGRect:self.bounds forKey:@"bounds"];
    [aCoder encodeFloat:self.circleWidth forKey:@"circleWidth"];
    [aCoder encodeObject:self.circleColor forKey:@"circleColor"];
    [aCoder encodeObject:self.points forKey:@"points"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _center = [aDecoder decodeCGPointForKey:@"center"];
        _radius = [aDecoder decodeFloatForKey:@"radius"];
        _bounds = [aDecoder decodeCGRectForKey:@"bounds"];
        _circleWidth = [aDecoder decodeFloatForKey:@"circleWidth"];
        _circleColor = [aDecoder decodeObjectForKey:@"circleColor"];
        _points = [aDecoder decodeObjectForKey:@"points"];
    }
    return self;
}

@end
