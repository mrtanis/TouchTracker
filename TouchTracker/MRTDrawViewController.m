//
//  MRTDrawViewController.m
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTDrawViewController.h"
#import "MRTDrawView.h"

@interface MRTDrawViewController () <MRTDrawViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
//@property (nonatomic) MRTDrawView *viewToDraw;
//背景视图，白板或者图片
@property (nonatomic, weak) UIImageView *backgroundView;
@end

@implementation MRTDrawViewController
/*
- (void)loadView
{
    self.viewToDraw = [[MRTDrawView alloc] initWithFrame:self.view.bounds];
    [self.viewToDraw redrawLines];*/
    
    /*
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanButton setFrame:CGRectMake(0, 642, 375, 30)];
    [cleanButton addTarget:self.viewToDraw action:@selector(cleanAll) forControlEvents:UIControlEventTouchUpInside];
    [cleanButton setTitle:@"Clean All" forState:0];
    [cleanButton setTitleColor:[UIColor grayColor] forState:0];
    cleanButton.backgroundColor = [UIColor whiteColor];
    [self.viewToDraw addSubview:cleanButton];
    */
    //[self.view addSubview:self.viewToDraw];
    
    
//}

- (void)viewDidLoad
{
    //画板背景
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundView.backgroundColor = [UIColor whiteColor];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [defaults dataForKey:@"picBG"];
    UIImage *image = [UIImage imageWithData:imageData];
    backgroundView.image = image;
    [self.view addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    //画板
    self.viewToDraw = [[MRTDrawView alloc] initWithFrame:self.view.bounds];
    self.viewToDraw.fatherView = self.view;
    self.viewToDraw.backgroundView = _backgroundView;
    self.viewToDraw.picBG = _backgroundView.image;
    self.viewToDraw.delegate = self;
    [self.viewToDraw redrawLines];
    
    [self.view addSubview:self.viewToDraw];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)shouldPresentImagePicker:(BOOL)flag
{
    if (flag) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        self.backgroundView.image = nil;
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"完成照片选择");
    //通过info字典获取选择的照片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    _backgroundView.image = image;
    _viewToDraw.picBG = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.viewToDraw.whiteBoardMode = YES;
    [self.viewToDraw setPaintingModeButtonState];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)shouldPresentAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否清屏？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.viewToDraw deleteAll];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sharePainting:(UIImage *)painting
{
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[painting] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)painting:(UIImage *)painting didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *title = @"保存成功";
    NSString *message = nil;
    
    if (error) {
        title = @"出错啦！";
        message = [NSString stringWithFormat:@"%@", error.description];
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(dismissAlert:) userInfo:alert repeats:NO];
}

- (void)dismissAlert:(NSTimer *)timer
{
    UIAlertController *alert = timer.userInfo;
    [alert dismissViewControllerAnimated:YES completion:nil];
    alert = nil;
    [timer invalidate];
    
}


- (void)savePicBG
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:UIImageJPEGRepresentation(_backgroundView.image, 1) forKey:@"picBG"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewToDraw saveLines];
}*/

@end
