//
//  MRTDrawViewController.m
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTDrawViewController.h"
#import "MRTDrawView.h"

@interface MRTDrawViewController ()
//@property (nonatomic) MRTDrawView *viewToDraw;
@end

@implementation MRTDrawViewController

- (void)loadView
{
    self.viewToDraw = [[MRTDrawView alloc] initWithFrame:CGRectZero];
    [self.viewToDraw redrawLines];
    
    /*
    UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanButton setFrame:CGRectMake(0, 642, 375, 30)];
    [cleanButton addTarget:self.viewToDraw action:@selector(cleanAll) forControlEvents:UIControlEventTouchUpInside];
    [cleanButton setTitle:@"Clean All" forState:0];
    [cleanButton setTitleColor:[UIColor grayColor] forState:0];
    cleanButton.backgroundColor = [UIColor whiteColor];
    [self.viewToDraw addSubview:cleanButton];
    */
    self.view = self.viewToDraw;
    
    
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
