//
//  VLOPathAnimationMaker.m
//

#import "VLOPathAnimationMaker.h"

@interface VLOPathAnimationMaker()

@property (strong, nonatomic) CALayer *animationLayer;
@property (strong, nonatomic) VLOPathMaker *pathMaker;
@property (strong, nonatomic) UIView *receivedView;
@property (strong, nonatomic) NSArray *markerList;

@property () CGFloat screenWidth;
@property () CGFloat screenHeight;

@end

@implementation VLOPathAnimationMaker

- (id) initWithView:(UIView *)summaryView andMarkerList:(NSArray *)markerList {
    self = [super init];
    _receivedView = summaryView;
    _animationLayer = [[CALayer alloc] init];
    _pathMaker = [[VLOPathMaker alloc] init];
    [_receivedView.layer addSublayer:_animationLayer];
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _markerList = markerList;
    return self;
}

- (void) animatePath {
    [self eraseAll];
    [self drawFromMarkerArray:_markerList];
}

- (void) drawFromMarkerArray:(NSArray *)markerList {
    CGFloat totalDuration = 0;
    for (NSInteger i = 1; i < markerList.count; i++) {
        // 새로운 path 생성.
        Marker *prevMarker = [markerList objectAtIndex:i-1];
        Marker *currMarker = [markerList objectAtIndex:i];
        CGPoint prevPoint = CGPointMake(prevMarker.x, prevMarker.y);
        CGPoint currPoint = CGPointMake(currMarker.x, currMarker.y);
        UIBezierPath *newPath = [_pathMaker pathBetweenPoint:prevPoint point:currPoint];
        
        CGFloat duration = WHOLE_DURATION * (currPoint.x - prevPoint.x) / _screenWidth;
        
        // Path 애니메이션 추가.
        [self addPathAnimation:newPath duration:duration delay:totalDuration];
        
        // 마커 애니메이션 추가.
        Marker *marker = (Marker *) [markerList objectAtIndex:i-1];
        [self addMarkerAnimation:marker delay:totalDuration];
        
        totalDuration += duration;
        
    }
    // 마지막 마커 추가.
    Marker *marker = (Marker *) [markerList objectAtIndex:markerList.count-1];
    [self addMarkerAnimation:marker delay:totalDuration];
}

- (void) addPathAnimation:(UIBezierPath *)path duration:(CGFloat)duration delay:(CGFloat)delay {
    CAShapeLayer *pathLayer = [[CAShapeLayer alloc] init];
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor blackColor].CGColor;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.lineWidth = LINE_WIDTH;
    pathLayer.strokeStart = 0.0;
    pathLayer.strokeEnd = 1.0;
    pathLayer.lineJoin = kCALineJoinBevel;
    [_animationLayer addSublayer:pathLayer];
    
    CABasicAnimation *pathDrawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathDrawAnimation.duration  = duration;
    pathDrawAnimation.beginTime = CACurrentMediaTime() + delay;
    pathDrawAnimation.fillMode = kCAFillModeBackwards;
    pathDrawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathDrawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    [pathLayer addAnimation:pathDrawAnimation forKey:@"strokeEnd"];
}

- (void) addMarkerAnimation:(Marker *)marker delay:(CGFloat)delay {
    // 마커 생성.
    UIImageView *markerImageView = [[UIImageView alloc]
                                    initWithImage: [UIImage imageNamed:@"marker5.png"]];
    CGFloat markerLeft = marker.x - MARKER_SIZE/2;
    CGFloat markerTop = marker.y - MARKER_SIZE - 10;
    [markerImageView setFrame:CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE)];
    
    // 마커 애니메이션.
    markerImageView.alpha = 0;
    markerImageView.hidden = NO;
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:MARKER_ANIMATION_DURATION delay:delay options:options
                     animations:^{
                         markerImageView.alpha = 1;
                         [markerImageView setFrame:
                          CGRectMake(markerLeft,markerTop + MARKER_TRAVEL,MARKER_SIZE,MARKER_SIZE)];
                     } completion: nil];
    
    [_receivedView addSubview: markerImageView];
}

- (void) eraseAll {
    _animationLayer.sublayers = nil;
    
    // 마커 제거
    for (UIView *imageView in _receivedView.subviews) {
        if ([imageView isKindOfClass:[UIImageView class]]) {
            [imageView removeFromSuperview];
        }
    }
}

@end

