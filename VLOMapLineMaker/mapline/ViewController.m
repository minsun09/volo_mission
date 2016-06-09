//
//  ViewController.m
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;;
    
    _curveLength = _screenWidth - CURVE_HORIZONTAL_PADDING * 2;

    CGFloat initialCurveY = _screenHeight * CURVE_VERTICAL_RATIO;
    _start = CGPointMake(CURVE_HORIZONTAL_PADDING, initialCurveY);
    _end = CGPointMake(CURVE_HORIZONTAL_PADDING + _curveLength, initialCurveY);
    
    _mapLineMaker = [[VLOMapLineMaker alloc] init];
    
    _testView = [[TestView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    [_testView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_testView];

    [self testPointsInView];
    
    // Create button.
    CGFloat buttonLeft = BUTTON_PADDING;
    CGFloat buttonTop = _screenHeight * BUTTON_TOP_RATIO;
    CGFloat buttonWidth = _screenWidth - BUTTON_PADDING * 2;
    CGFloat buttonHeight = _screenHeight * BUTTON_HEIGHT_RATIO;
    UIButton *testPointsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [testPointsButton setFrame:CGRectMake(buttonLeft, buttonTop, buttonWidth, buttonHeight)];
    [testPointsButton setTitle:@"New random points" forState:UIControlStateNormal];
    [testPointsButton addTarget:self action:@selector(testPointsInView)
               forControlEvents:UIControlEventTouchUpInside];
    testPointsButton.backgroundColor=[UIColor grayColor];
    [self.view addSubview:testPointsButton];
    
}

- (void)testPointsInView {
    // Create random starting points.
    CGFloat curveY = _screenHeight * CURVE_VERTICAL_RATIO;

    _start.y = arc4random_uniform(CURVE_VERTICAL_VARIATION) + curveY;
    _end.y = arc4random_uniform(CURVE_VERTICAL_VARIATION) + curveY;
    
    _testView.path = [_mapLineMaker mapLineBetweenPoint:_start point:_end];
    
    [_testView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
