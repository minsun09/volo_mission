//
//  ViewController.h
//  mapline
//
//  Created by Seongmin on 6/7/16.
//  Copyright © 2016 Seongmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLOMapLineMaker.h"
#import "TestView.h"

#define BUTTON_PADDING 10
#define BUTTON_TOP_RATIO 0.75
#define BUTTON_HEIGHT_RATIO 0.09
#define CURVE_HORIZONTAL_PADDING 40
#define CURVE_VERTICAL_RATIO 0.45
#define CURVE_VERTICAL_VARIATION 30


@interface ViewController : UIViewController

@property (strong, nonatomic) VLOMapLineMaker *mapLineMaker;
@property (strong, nonatomic) TestView *testView;
@property () CGPoint start;
@property () CGPoint end;
@property () CGFloat screenWidth;
@property () CGFloat screenHeight;
@property () NSInteger curveLength;

@end

