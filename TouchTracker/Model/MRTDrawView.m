//
//  MRTDrawView.m
//  TouchTracker
//
//  Created by mrtanis on 2017/2/7.
//  Copyright © 2017年 mrtanis. All rights reserved.
//

#import "MRTDrawView.h"
#import "MRTLine.h"
#import "MRTCircle.h"
#import "MRTRealPath.h"

@interface MRTDrawView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableDictionary *circlesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedCircle;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, strong) NSMutableDictionary *pathsInProgress;
@property (nonatomic, strong) NSMutableArray *realPaths;
@property (nonatomic) CGPoint velocity;

@property (nonatomic, weak) MRTLine *selectedLine;


@property (strong, nonatomic) IBOutlet UIView *colorPanelView;
@property (weak, nonatomic) IBOutlet UIButton *selectedColorButton;
@property (nonatomic, strong) UIColor *selectedColor;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *colors;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
@property (nonatomic) CGFloat redValue;
@property (nonatomic) CGFloat greenValue;
@property (nonatomic) CGFloat blueValue;




@property (nonatomic) CGFloat selectedWidth;
@property (weak, nonatomic) IBOutlet UIButton *pathModeButton;
@property (weak, nonatomic) IBOutlet UIButton *lineModeButton;
@property (nonatomic) BOOL lineCircleMode;//直线和画圆模式
@property (strong, nonatomic) IBOutlet UIView *widthView;
@property (weak, nonatomic) IBOutlet UIButton *widthDotButton;
@property (weak, nonatomic) IBOutlet UISlider *widthSlider;

@end

@implementation MRTDrawView

- (NSMutableArray *)realPaths
{
    if (_realPaths == nil) {
        _realPaths = [[NSMutableArray alloc] init];
    }
    return _realPaths;
}

- (instancetype)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    
    if (self) {
        _linesInProgress = [[NSMutableDictionary alloc] init];
        _circlesInProgress = [[NSMutableDictionary alloc] init];
        _finishedLines = [[NSMutableArray alloc] init];
        _finishedCircle = [[NSMutableArray alloc] init];
        _pathsInProgress = [[NSMutableDictionary alloc] init];
        
        NSString *path = [self drawingArchivePath];
        _realPaths = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_realPaths) {
            _realPaths = [[NSMutableArray alloc] init];
        }
        
        self.backgroundColor = [UIColor whiteColor];
        _redValue = 0.0;
        _greenValue = 0.0;
        _blueValue = 0.0;
        _selectedColor = [UIColor colorWithRed:self.redValue green:self.greenValue blue:self.blueValue alpha:1];
        _selectedWidth = 5;
        _lineCircleMode = NO;
        //添加多点触摸支持
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer * doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        if (self.lineCircleMode) {
            doubleTapRecognizer.delaysTouchesBegan = YES;//在识别出点击手势之前避免向UIView发送touchesBegan：withEvent：消息（避免画出小红点）
        } else {
            doubleTapRecognizer.delaysTouchesBegan = NO;
        }
        [self addGestureRecognizer:doubleTapRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];

        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];//设置UITapGestureRecognizer在单击后不进行识别，直到确定不是双击手势后再识别为单击手势
        
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];;
        
        //添加下滑调出颜色选择面板手势
        UISwipeGestureRecognizer *colorChooseRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popupColorView:)];
        colorChooseRecognizer.numberOfTouchesRequired = 3;
        colorChooseRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:colorChooseRecognizer];
        
        //添加上滑调出线条宽度选择面板手势
        UISwipeGestureRecognizer *widthChooseRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popupWidthView:)];
        widthChooseRecognizer.numberOfTouchesRequired = 3;
        widthChooseRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:widthChooseRecognizer];
        
        //添加右滑撤销上一步手势
        /*UISwipeGestureRecognizer *undoRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(undo:)];
        widthChooseRecognizer.numberOfTouchesRequired = 3;
        widthChooseRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:undoRecognizer];*/
        
        /*
        UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cleanButton setFrame:CGRectMake(0, 642, 375, 30)];
        [cleanButton addTarget:self action:@selector(cleanAll) forControlEvents:UIControlEventTouchUpInside];
        [cleanButton setTitle:@"Clean All" forState:0];
        [cleanButton setTitleColor:[UIColor grayColor] forState:0];
        cleanButton.backgroundColor = [UIColor whiteColor];
        [self addSubview:cleanButton];
         */
    }

    return self;
}

- (void)popupColorView:(UIGestureRecognizer *)gr
{
    [self.colorPanelView removeFromSuperview];
    CGRect frame = CGRectMake(0, 0, self.window.bounds.size.width, 261);
    [[NSBundle mainBundle] loadNibNamed:@"MRTColorPanel" owner:self options:nil];
    UIView *colorPanel = self.colorPanelView;
    [colorPanel setFrame:frame];

    //代码实现毛玻璃效果，此处已通过xib实现，仅作为方法演示。代码添加毛玻璃时注意按钮也许通过代码添加为毛玻璃视图的子视图
    /*
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = frame;
    [colorPanel addSubview:effectView];
     */
    
    self.selectedColorButton.backgroundColor = self.selectedColor;
    self.redSlider.value = self.redValue;
    self.greenSlider.value = self.greenValue;
    self.blueSlider.value = self.blueValue;
    
    [self addSubview:colorPanel];
    [self setNeedsDisplay];
}

- (void)popupWidthView:(UIGestureRecognizer *)gr
{
    [self.widthView removeFromSuperview];
    CGRect frame = CGRectMake(0, self.bounds.size.height - 76, self.bounds.size.width, 76);
    [[NSBundle mainBundle] loadNibNamed:@"MRTWidthView" owner:self options:nil];
    UIView *widthView = self.widthView;
    [widthView setFrame:frame];
    
    CGFloat halfWidth = self.selectedWidth / 2.0;
    CGRect widthDotframe = CGRectMake(44 - halfWidth, 24 - halfWidth, self.selectedWidth, self.selectedWidth);
    [self.widthDotButton setFrame:widthDotframe];
    self.widthDotButton.layer.cornerRadius = halfWidth;
    
    self.pathModeButton.layer.cornerRadius = 5;
    self.lineModeButton.layer.cornerRadius = 5;
    
    UIColor *color = [UIColor colorWithRed:0.019 green:0.473 blue:0.987 alpha:1];
    if (self.lineCircleMode) {
        self.lineModeButton.backgroundColor = color;
        [self.lineModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.pathModeButton.backgroundColor = color;
        [self.pathModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    

    [self.widthView addSubview:self.widthDotButton];
    [self.widthSlider setValue:self.selectedWidth animated:YES];
    [self addSubview:widthView];
    [self setNeedsDisplay];
}

- (void)undo:(UIGestureRecognizer *)gr
{
    [self.realPaths removeLastObject];
    [self setNeedsDisplay];
}

# pragma mark 颜色选择

- (IBAction)redValue:(UISlider *)sender {
    self.redValue = sender.value;
    self.selectedColor = [UIColor colorWithRed:self.redValue green:self.greenValue blue:self.blueValue alpha:1];
    self.selectedColorButton.backgroundColor = self.selectedColor;
}
- (IBAction)greenValue:(UISlider *)sender {
    self.greenValue = sender.value;
    self.selectedColor = [UIColor colorWithRed:self.redValue green:self.greenValue blue:self.blueValue alpha:1];
    self.selectedColorButton.backgroundColor = self.selectedColor;
}
- (IBAction)blueValue:(UISlider *)sender {
    self.blueValue = sender.value;
    self.selectedColor = [UIColor colorWithRed:self.redValue green:self.greenValue blue:self.blueValue alpha:1];
    self.selectedColorButton.backgroundColor = self.selectedColor;
}


- (IBAction)changeColor:(UIButton *)sender {
    self.selectedColor = sender.backgroundColor;
    self.selectedColorButton.backgroundColor = self.selectedColor;
}

- (IBAction)pathMode:(id)sender {
    UIColor *color = [UIColor colorWithRed:0.019 green:0.473 blue:0.987 alpha:1];
    self.lineCircleMode = NO;
    self.lineModeButton.backgroundColor = [UIColor whiteColor];
    [self.lineModeButton setTitleColor:color forState:UIControlStateNormal];
    self.pathModeButton.backgroundColor = color;
    [self.pathModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
}
- (IBAction)lineMode:(id)sender {
    UIColor *color = [UIColor colorWithRed:0.019 green:0.473 blue:0.987 alpha:1];
    self.lineCircleMode = YES;
    self.lineModeButton.backgroundColor = color;
    [self.lineModeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pathModeButton.backgroundColor = [UIColor whiteColor];
    [self.pathModeButton setTitleColor:color forState:UIControlStateNormal];

}

# pragma mark 线条宽度调节

- (IBAction)changeWidth:(id)sender {
    self.selectedWidth = self.widthSlider.value;
    CGFloat halfWidth = self.selectedWidth / 2.0;
    CGRect widthDotframe = CGRectMake(44 - halfWidth, 24 - halfWidth, self.selectedWidth, self.selectedWidth);
    [self.widthDotButton setFrame:widthDotframe];
    self.widthDotButton.layer.cornerRadius = halfWidth;
    [self setNeedsDisplay];
}

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否清屏？" message:nil delegate:self cancelButtonTitle:@"怂了" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 默认取消按钮索引为0
    if (buttonIndex == 0) {
        NSLog(@"点击了取消按钮");
    } else {
        NSLog(@"点击了确定按钮");
        [self.linesInProgress removeAllObjects];
        [self.circlesInProgress removeAllObjects];
        [self.pathsInProgress removeAllObjects];
        [self.finishedCircle removeAllObjects];
        [self.finishedLines removeAllObjects];
        [self.realPaths removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap");
    CGRect rect = CGRectMake(0, 261, self.bounds.size.width, self.bounds.size.height - 261 - 76);
    CGPoint point = [gr locationInView:self];
    if (CGRectContainsPoint(rect, point)) {
        [self.colorPanelView removeFromSuperview];
        [self.widthView removeFromSuperview];
    }
    
    
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        
        //使视图成为UIMenuItem动作消息的目标
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        //创建标题为“Delete”的UIMenuItem对象
        UIMenuItem *deleteitem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        menu.menuItems = @[deleteitem];
        //先为UIMenuController对象设置显示区域，然后将其设为可见
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES animated:YES];
    } else {
        //如果没有选中的线条，就隐藏UIMenuController对象
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}
//将某个自定义UIView子类对象设置为第一响应对象，就必须覆盖该对象的canBecomeFirstResponder方法并返回YES
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)strokeLine:(MRTLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    bp.lineWidth = line.lineWidth;
    bp.lineCapStyle = kCGLineCapRound;//线的结尾为圆形，半径为二分之一线宽
    [line.lineColor set];
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)strokePath:(MRTRealPath *)path
{
    [path.pathColor set];
    [path.realPath stroke];
}

- (void)strokeCircle:(MRTCircle *)circle
{
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circle.bounds];
    circlePath.lineWidth = circle.circleWidth;
    [circle.circleColor set];
    [circlePath stroke];
}

- (MRTLine *)lineAtPoint:(CGPoint)p
{
    for (MRTLine *line in self.finishedLines) {
        CGPoint start = line.begin;
        CGPoint end = line.end;
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y -start.y);
            //如果线条的某个点和p的距离在20点以内，就返回相应的BNRLine对象
            if (hypot(x - p.x, y - p.y) < 10.0) {
                return line;
            }
        }
    }
    return nil;
}


- (void)deleteLine:(id)sender
{
    [self.finishedLines removeObject:self.selectedLine];
    [self.realPaths removeObject:self.selectedLine];
    [self setNeedsDisplay];
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        //////不明白这步是什么作用??????//////
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
}

//长按时UIPanGestureRecognizer也能收到相关的UITouch对象
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    return NO;
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    //通过移动速度设定线宽
    /*
    if ([gr state] == UIGestureRecognizerStateBegan) {
        self.velocity = [gr velocityInView:self];
        CGFloat v = hypot(self.velocity.x, self.velocity.y);
        self.selectedWidth = v / 6000.0 * 20 + 5;
    }
    if (self.moveRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint v = [gr velocityInView:self];
        CGFloat new = hypot(v.x, v.y);
        CGFloat old = hypot(self.velocity.x, self.velocity.y);
        if (new > old) {
            self.velocity = v;
            self.selectedWidth = new / 6000.0 * 20 + 5;
        }
    }
     */
    
    if (!self.selectedLine) {
        return;
    }

    
    if ([gr state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menu=[UIMenuController sharedMenuController];
        if (menu.isMenuVisible==YES) {
            [menu setMenuVisible:NO animated:YES];
            self.selectedLine = nil;
            return;
        }
    }

    if (self.moveRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:self];//以CGPoint保存移动的距离，并不是坐标
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        [self setNeedsDisplay];
        [gr setTranslation:CGPointZero inView:self];//重要，报告手指当前位置，以实现增量报告拖移距离（每次相对于上一次的距离，而不是相对第一次的距离）
        
    }
}

#define ARC4RANDOM_MAX 0x100000000
- (void)drawRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    //绘制实时路径
    //绘制已完成路径
    if (self.realPaths) {
        for (int i = 0; i < self.realPaths.count; i++){
            if ([self.realPaths[i] isKindOfClass:[MRTRealPath class]]) {
                [self strokePath:self.realPaths[i]];
            } else if ([self.realPaths[i] isKindOfClass:[MRTLine class]]) {
                MRTLine *line = self.realPaths[i];
                [self strokeLine:line];
            } else if ([self.realPaths[i] isKindOfClass:[MRTCircle class]]) {
                MRTCircle *circle = self.realPaths[i];
                [self strokeCircle:circle];
            }
        }
        
    }
    //绘制正在进行的路径
    NSArray *values = [self.pathsInProgress allValues];
    for (int i = 0; i < values.count; i++) {
        if ([values[i] isKindOfClass:[MRTRealPath class]]) {
            
            [self strokePath:values[i]];
        } else if ([values[i] isKindOfClass:[MRTLine class]]) {
            
            [self strokeLine:values[i]];
        } else if ([values[i] isKindOfClass:[MRTCircle class]]) {
            [self strokeCircle:values[i]];
        }
    }
    

    //绘制已完成的圆
    [[UIColor blackColor] set];
    if (self.finishedCircle.count > 0) {
        for (MRTCircle *circle in self.finishedCircle) {
            UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circle.bounds];
            circlePath.lineWidth = 8;
            CGFloat hue = circle.radius / (CGFloat)(self.bounds.size.width / 2);
            //NSLog(@"hue = %f", hue);
            UIColor *randomColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
            [randomColor set];
            [circlePath stroke];
        }
    }
    //将选中的线条绘制为绿色
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //像控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    
    
    if (touches.count ==2 && self.lineCircleMode) {
        for (UITouch *t in touches) {
            CGPoint location = [t locationInView:self];
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            self.circlesInProgress[key] = [NSValue valueWithCGPoint:location];
        }
        NSArray *twoPoints = [self.circlesInProgress allValues];
        MRTCircle *circle = [[MRTCircle alloc] initWithBoundaryPoints:twoPoints];
        circle.circleColor = self.selectedColor;
        circle.circleWidth = self.selectedWidth;
        [self.pathsInProgress setObject:circle forKey:@"circle"];
    } else {
        for (UITouch *t in touches) {
            CGPoint location = [t locationInView:self];
            NSValue *key = [NSValue valueWithNonretainedObject:t];
 
            /*MRTRealPath *path = [[MRTRealPath alloc] init];
            path.path = CGPathCreateMutable();
            path.pathWidth = self.selectedWidth;
            path.pathColor = self.selectedColor;
            CGPathMoveToPoint(path.path, nil, location.x, location.y);
            self.pathsInProgress[key] = path;*/

            //如果直线画圆模式开启，则启用直线画圆模式
            if (self.lineCircleMode) {
                MRTLine *line = [[MRTLine alloc] init];
                line.begin = location;
                line.end = location;
                line.lineColor = self.selectedColor;
                line.lineWidth = self.selectedWidth;
                self.pathsInProgress[key] = line;
            } else {
                //否则使用实时路径模式
                MRTRealPath *path = [[MRTRealPath alloc] init];
                path.realPath = [UIBezierPath bezierPath];
                path.realPath.lineWidth = self.selectedWidth;
                path.realPath.lineCapStyle = kCGLineCapRound;
                path.pathColor = self.selectedColor;
                [path.realPath moveToPoint:location];
                self.pathsInProgress[key] = path;
            }
        }
        /*UITouch *t = [touches anyObject];
         
         //根据触摸位置创建MRTLine对象
         CGPoint location = [t locationInView:self];
         
         self.currentLine = [[MRTLine alloc] init];
         self.currentLine.begin = location;
         self.currentLine.end = location;*/
    }
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //像控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (touches.count != 3) {
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            CGPoint location = [t locationInView:self];
            //如果直线画圆模式开启，则启用直线画圆模式
            if (self.lineCircleMode) {
                MRTLine *line = self.pathsInProgress[key];
                line.end = location;
                line.lineWidth = self.selectedWidth;
                
                NSValue *pointValue = self.circlesInProgress[key];
                if (pointValue) {
                    self.circlesInProgress[key] = [NSValue valueWithCGPoint:location];
                }
            } else {
                MRTRealPath *path = self.pathsInProgress[key];
                [path.realPath addLineToPoint:location];
            }
            
        }
        if (self.circlesInProgress) {
            NSArray *twoPoints = [self.circlesInProgress allValues];
            MRTCircle *circle = [[MRTCircle alloc] initWithBoundaryPoints:twoPoints];
            circle.circleColor = self.selectedColor;
            circle.circleWidth = self.selectedWidth;
            [self.pathsInProgress setObject:circle forKey:@"circle"];

        }
    }
    
    
    /*UITouch *t = [touches anyObject];
    CGPoint location = [t locationInView:self];
    
    self.currentLine.end = location;*/
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //像控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (touches.count != 3) {
        for (UITouch *t in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            
            
            if (!self.lineCircleMode) {
                MRTRealPath *path = self.pathsInProgress[key];
                [self.realPaths addObject:path];
                [self.pathsInProgress removeObjectForKey:key];
                
            } else {
                MRTLine *line = self.pathsInProgress[key];
                if (!self.circlesInProgress[key] && line) {
                    [self.realPaths addObject:line];
                    [self.finishedLines addObject:line];
                    
                    [self.pathsInProgress removeObjectForKey:key];
                }
            }
        }
        if (self.pathsInProgress[@"circle"]) {
            [self.realPaths addObject:self.pathsInProgress[@"circle"]];
            [self.pathsInProgress removeObjectForKey:@"circle"];
            [self.circlesInProgress removeAllObjects];
        }
    }
    
    
    /*[self.finishedLines addObject:self.currentLine];
    
    self.currentLine = nil;*/
    
    [self setNeedsDisplay];
}

//系统终端应用（如接到电话），触摸事件会被取消，这时应将应用恢复到触摸事件发生前的状态，即取消所有正在绘制的线条
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //像控制台输出日志，查看触摸事件发生顺序
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
        [self.circlesInProgress removeObjectForKey:key];
        [self.pathsInProgress removeObjectForKey:key];
    }
    
    [self setNeedsDisplay];
}

# pragma saving and loading data

- (void)saveLines
{
    NSMutableArray *linesToBeSaved = [[NSMutableArray alloc] init];
    for (MRTLine *finishedLine in self.finishedLines) {
        [linesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedLine.begin.x]];
        [linesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedLine.begin.y]];
        [linesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedLine.end.x]];
        [linesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedLine.end.y]];
    }
    
    NSMutableArray *circlesToBeSaved = [[NSMutableArray alloc] init];
    for (MRTCircle *finishedCircle in self.finishedCircle) {
        [circlesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedCircle.center.x]];
        [circlesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedCircle.center.y]];
        [circlesToBeSaved addObject:[[NSNumber alloc]initWithFloat:finishedCircle.radius]];
    }
    [linesToBeSaved writeToFile:@"/Users/mrtanis/Desktop/lines/_lines" atomically:YES];
    [circlesToBeSaved writeToFile:@"/Users/mrtanis/Desktop/lines/_circles" atomically:YES];
    NSLog(@"saveLines method called");
}

- (void)redrawLines
{
    NSMutableArray *linesToBeRedraw = [[NSMutableArray alloc] initWithContentsOfFile:@"/Users/mrtanis/Desktop/lines/_lines"];
    if (linesToBeRedraw.count<4) { // If the number of entries is less than 4, then no line should be drawn
        return;
    }
    // Double check the number of lines imported
    NSLog(@"Imported %lu lines from savefile",(linesToBeRedraw.count)/4);
    // Adding them to the finishedLines array of self, the method drawRect shall automatically take care of the drawing work
    for (int i = 0; i < (linesToBeRedraw.count - 3); i += 4) {
        MRTLine *linex = [[MRTLine alloc]init];
        linex.begin = CGPointMake([linesToBeRedraw[i] floatValue], [linesToBeRedraw[i+1] floatValue]);
        linex.end = CGPointMake([linesToBeRedraw[i+2] floatValue], [linesToBeRedraw[i+3] floatValue]);
        [self.finishedLines addObject:linex];
    }
    
    NSMutableArray *circlesToBeRedraw = [[NSMutableArray alloc] initWithContentsOfFile:@"/Users/mrtanis/Desktop/lines/_circles"];
    if (circlesToBeRedraw.count < 3) {
        return;
    }
    for (int i = 0; i < circlesToBeRedraw.count - 2; i += 3) {
        CGFloat x1 = [circlesToBeRedraw[i] floatValue];
        CGFloat y1 = [circlesToBeRedraw[i+1] floatValue] - [circlesToBeRedraw[i+2] floatValue];
        CGFloat x2 = [circlesToBeRedraw[i] floatValue];
        CGFloat y2 = [circlesToBeRedraw[i+1] floatValue] + [circlesToBeRedraw[i+2] floatValue];
        CGPoint point1 = CGPointMake(x1, y1);
        CGPoint point2 = CGPointMake(x2, y2);
        NSArray *points = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:point1], [NSValue valueWithCGPoint:point2], nil];
        MRTCircle *circlex = [[MRTCircle alloc] initWithBoundaryPoints:points];
        [self.finishedCircle addObject:circlex];
    }

    NSLog(@"redrawLines method called");
}

# pragma mark 保存

//获取固化路径
- (NSString *)drawingArchivePath
{
    NSArray *documentDerectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDerectory = [documentDerectories firstObject];
    
    return [documentDerectory stringByAppendingPathComponent:@"drawing.archive"];
}

- (BOOL)saveDrawing
{
    NSString *path = [self drawingArchivePath];
    
    //固化成功返回YES
    return [NSKeyedArchiver archiveRootObject:self.realPaths toFile:path];
}



@end
