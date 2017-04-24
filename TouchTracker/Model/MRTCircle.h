//
//  MRTCircle.h
//  TouchTracker
//
//  Created by mrtanis on 2017/2/23.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MRTCircle : NSObject <NSCoding>

@property (nonatomic) CGPoint center;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGRect bounds;
@property (nonatomic) CGFloat circleWidth;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) NSMutableArray *points;


- (instancetype)initWithBoundaryPoints:(NSArray *)points;
@end
