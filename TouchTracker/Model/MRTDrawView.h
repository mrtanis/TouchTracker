//
//  MRTDrawView.h
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MRTPathMode) {
    MRTPathModeRealPath = 1,
    MRTPathModeLineCircle
};

typedef NS_ENUM(NSInteger, MRTPaintMode) {
    MRTPaintModeOnPic = 1,
    MRTPaintModeWhiteBoard
};

@protocol MRTDrawViewDelegate <NSObject>
@optional
- (void)shouldPresentImagePicker:(BOOL)flag;
- (void)shouldPresentAlert;
- (void)sharePainting:(UIImage *)painting;
- (void)painting:(UIImage *)painting didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end
@interface MRTDrawView : UIView
@property (nonatomic, weak) id <MRTDrawViewDelegate> delegate;
@property (nonatomic, weak) UIView *fatherView;
@property (nonatomic, weak) UIImageView *backgroundView;
@property (nonatomic) MRTPaintMode paintMode;//白板模式
@property (nonatomic, strong) UIImage *picBG;//背景图片
- (void)saveLines;
- (void)redrawLines;
- (BOOL)saveDrawing;
- (void)deleteAll;

- (void)setPaintingModeButtonState;
@end
