//
//  MRTRealPath.h
//  TouchTracker
//
//  Created by mrtanis on 2017/3/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MRTRealPath : NSObject <NSCoding>

@property (nonatomic, strong) UIColor *pathColor;
@property (nonatomic, strong) UIBezierPath *realPath;
@property (nonatomic) CGFloat pathWidth;

@end
