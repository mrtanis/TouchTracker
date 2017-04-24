//
//  MRTDrawView.h
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRTDrawView : UIView

- (void)saveLines;
- (void)redrawLines;

- (BOOL)saveDrawing;
@end
