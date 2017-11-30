//
//  MRTDrawViewController.h
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTDrawView.h"

@interface MRTDrawViewController : UIViewController
@property (nonatomic, readwrite) MRTDrawView *viewToDraw;

- (void)savePicBG;

@end
