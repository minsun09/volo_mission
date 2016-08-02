//
//  VLOSummarySegment.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummarySegment.h"

@interface VLOSummarySegment ()

@property (nonatomic, strong) UIView *segmentView;
@property (nonatomic, strong) UIView *segmentContentView;
@property () BOOL segmentUsesCustomImage;
@property () BOOL segmentContentUsesCustomImage;
@property () NSString *segmentImageName;
@property () NSString *contentImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;
@property () BOOL fromMarkerXBigger;

@property (strong, nonatomic) VLOSummaryMarker *leftMarker;
@property (strong, nonatomic) VLOSummaryMarker *rightMarker;

@end

@implementation VLOSummarySegment

- (id) initFrom:(VLOSummaryMarker *)fromMarker to:(VLOSummaryMarker *)toMarker {
    self = [super init];
    _fromMarker = fromMarker;
    _toMarker = toMarker;
    _curved = NO;
    _leftToRight = YES;
    _hasSegmentContent = NO;
    _leftMarker  = (fromMarker.x < toMarker.x) ? fromMarker : toMarker;
    _rightMarker = (fromMarker.x < toMarker.x) ? toMarker : fromMarker;
    return self;
}

- (void) setSegmentImage:(NSString *)segmentImageName {
    _segmentUsesCustomImage = YES;
    
    _segmentImageName = segmentImageName;
}

- (void) setSegmentContentImage:(NSString *)contentImageName {
    _hasSegmentContent = YES;
    _segmentContentUsesCustomImage = YES;
    
    _contentImageName = contentImageName;
}

- (UIView *) getDrawableView {
    
    CGFloat xDiff = fabs(_toMarker.x - _fromMarker.x);
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y)/2;
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    if (_curved) {
        _drawableLeft = _leftToRight? _leftMarker.x : _leftMarker.x - curveRadius - SEGMENT_CONTENT_SIZE/2;
    } else {
        _drawableLeft = _leftToRight? _fromMarker.x : _toMarker.x;
    }
    _drawableTop    = _curved? _fromMarker.y : _fromMarker.y - SEGMENT_CONTENT_SIZE;
    _drawableWidth  = _curved? xDiff + curveRadius + SEGMENT_CONTENT_SIZE/2 : xDiff;
    _drawableHeight = _curved? MAX(_toMarker.y - _fromMarker.y, SEGMENT_CONTENT_SIZE) : SEGMENT_CONTENT_SIZE;
    
    // 선과 선 장식 생성.
    [self initializeSegmentView];
    if (_hasSegmentContent) [self initializeSegmentContentView];
    
    // 선과 선 장식 묶음이 담길 뷰 생성.
    UIView *drawableView = [[UIView alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];
    [drawableView addSubview:_segmentView];
    if (_hasSegmentContent) [drawableView addSubview:_segmentContentView];
    
    //[drawableView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:0.6 alpha:0.4]];
    
    return drawableView;
}

- (void) initializeSegmentView {
    
    CGFloat curveRadius = fabs(_toMarker.y - _fromMarker.y) / 2;
    
    CGFloat segmentLeft   = 0;
    CGFloat segmentTop    = 0;
    CGFloat segmentWidth  = _curved? _drawableWidth - SEGMENT_CONTENT_SIZE/2 : _drawableWidth;
    CGFloat segmentHeight = _curved? curveRadius * 2 : 0;
    
    // (0,0)에서 시작하는 프레임에 맞춘 fromMarker과 toMarker 좌표.
    CGFloat fromMarkerX = _fromMarker.x - _drawableLeft;
    CGFloat fromMarkerY = _curved? 0 : SEGMENT_CONTENT_SIZE;
    CGPoint fromMarker  = CGPointMake(fromMarkerX, fromMarkerY);
    
    CGFloat toMarkerX   = _toMarker.x - _drawableLeft;
    CGFloat toMarkerY   = _curved? _drawableHeight : SEGMENT_CONTENT_SIZE;
    CGPoint toMarker    = CGPointMake(toMarkerX, toMarkerY);
    
    // _segmentView 생성.
    if (_segmentUsesCustomImage) {
        
        UIImage *segmentImage= [UIImage imageNamed:_segmentImageName ];
        _segmentView = [[UIImageView alloc] initWithImage:segmentImage];
        _segmentView.frame = CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight);
        
    } else {
        _segmentView = [[UIView alloc] initWithFrame:CGRectMake(segmentLeft, segmentTop, segmentWidth, segmentHeight)];
        UIBezierPath *segmentPath = [UIBezierPath bezierPath];
        [segmentPath moveToPoint:fromMarker];
        
        if (_curved) {
            CGFloat arcCenterX =_leftToRight? _rightMarker.x - _drawableLeft : _leftMarker.x - _drawableLeft;
            CGPoint curveStartPoint = CGPointMake(arcCenterX, fromMarkerY);
            CGPoint arcCenter = CGPointMake(arcCenterX, fromMarkerY + curveRadius);
            
            [segmentPath addLineToPoint:curveStartPoint];
            [segmentPath addArcWithCenter:arcCenter radius:curveRadius startAngle:3*M_PI/2 endAngle:M_PI_2 clockwise:_leftToRight];
            [segmentPath addLineToPoint:toMarker];
            
        } else {
            [segmentPath addLineToPoint:toMarker];
        }
        
        CAShapeLayer *segmentLayer = [CAShapeLayer layer];
        [segmentLayer setPath:segmentPath.CGPath];
        [segmentLayer setStrokeColor:[VOLO_COLOR CGColor]];
        [segmentLayer setLineWidth:3.0];
        [segmentLayer setFillColor:[[UIColor clearColor] CGColor]];
        
        [_segmentView.layer addSublayer:segmentLayer];
    }
}

- (void) initializeSegmentContentView {
    
    // Segment Content의 frame을 구하는 로직.
    CGFloat contentLeft;
    if (_curved) {
        contentLeft = _leftToRight? _drawableWidth - SEGMENT_CONTENT_SIZE : 0;
    } else {
        contentLeft = _drawableWidth/2 - SEGMENT_CONTENT_SIZE/2;
    }
    CGFloat contentTop;
    
    // _segmentContentView 생성.
    if (_segmentContentUsesCustomImage) {
        
        UIImage *contentImage = [UIImage imageNamed:_contentImageName];
        CGFloat imageWidthHeightRatio = contentImage.size.height / contentImage.size.width;
        CGFloat imageHeight = imageWidthHeightRatio * SEGMENT_CONTENT_SIZE;
        
        contentTop = _curved? _drawableHeight/2 - imageHeight/2 : imageHeight - LINE_WIDTH; // Segment와 겹쳐서 LINE_WIDTH만큼 빼준다.
        _segmentContentView = [[UIImageView alloc] initWithImage:contentImage];
        _segmentContentView.frame = CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, imageHeight);
        [_segmentContentView setBackgroundColor:[UIColor whiteColor]];
        
    } else {
        contentTop = _curved? _drawableHeight/2 - SEGMENT_CONTENT_SIZE/2 : 0;
        _segmentContentView = [[UIView alloc] initWithFrame:
                               CGRectMake(contentLeft, contentTop, SEGMENT_CONTENT_SIZE, SEGMENT_CONTENT_SIZE)];
    }
}

@end
