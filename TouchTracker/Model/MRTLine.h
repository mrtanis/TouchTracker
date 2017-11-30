//
//  MRTLine.h
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MRTLine : NSObject <NSCoding>


@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
- (double)angleOfLine;


@end
