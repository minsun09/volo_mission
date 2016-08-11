//
//  VLOSummaryMarker.m
//  Volo
//
//  Created by Seongmin on 7/29/16.
//  Copyright © 2016 SK Planet. All rights reserved.
//

#import "VLOSummaryMarker.h"

@interface VLOSummaryMarker ()

@property (nonatomic) VLOLog *log;
@property (nonatomic) VLOPlace *place;

@property (nonatomic, strong) UIView *markerView;
@property (nonatomic, strong) UIView *markerIconView;
@property (nonatomic, strong) UILabel *markerLabel;

@property () BOOL markerUsesCustomImage;
@property () BOOL markerImageIsDay;
@property () BOOL markerImageIsFlag;

@property () NSString *markerImageName;

@property () CGFloat drawableLeft;
@property () CGFloat drawableTop;
@property () CGFloat drawableWidth;
@property () CGFloat drawableHeight;

@end

@implementation VLOSummaryMarker

- (id) initWithLog:(VLOLog *)log andPlace:(VLOPlace *)place {
    self = [super init];
    
    _log = log;
    _place = place;
    
    _markerUsesCustomImage = NO;
    _markerImageIsDay = NO;
    _markerImageIsFlag = NO;
    _hasMarkerIcon = NO;
    
    return self;
}

- (void) setMarkerImage:(NSString *)markerImageName isDay:(BOOL)isDay isFlag:(BOOL)isFlag {
    _markerImageIsDay = isDay;
    _markerImageIsFlag = isFlag;
    _markerUsesCustomImage = YES;
    _markerImageName = markerImageName;
}

- (void) setMarkerIconImage:(NSString *)iconImageName {
    _hasMarkerIcon = YES;
    _iconImageName = iconImageName;
}

- (UIView *) getDrawableView {
    
    // 모든 컴포넌트에 공유되는 Frame 변수들.
    _drawableLeft   = _x - MARKER_ICON_WIDTH/2.0;
    _drawableTop    = _y + SEGMENT_OFFSET - MARKER_ICON_HEIGHT;
    _drawableWidth  = MARKER_ICON_WIDTH;
    _drawableHeight = MARKER_ICON_HEIGHT + MARKER_LABEL_HEIGHT;

    // 마커와 마커 장식 묶음이 담길 뷰 생성.
    UIButton *drawableView = [[UIButton alloc] initWithFrame:CGRectMake(_drawableLeft, _drawableTop, _drawableWidth, _drawableHeight)];

    // 마커 레이블.
    [self initializeMarkerLabel];
    [drawableView addSubview:_markerLabel];
    
    // 마커 그림.
    if (_hasMarkerIcon) {
        [self initializeMarkericonView];
        [drawableView addSubview:_markerIconView];
    }
    
    BOOL drawMarker = !_hasMarkerIcon || _markerImageIsDay || _markerImageIsFlag;
    
    // 마커 점.
    if (drawMarker) {
        [self initializeMarkerView];
        [drawableView addSubview:_markerView];
    }

    return drawableView;
}

- (void) initializeMarkerView {
    if (_markerView) return;
    
    
    CGFloat markerTop, markerLeft, markerWidth, markerImageSize;
    
    if (_markerUsesCustomImage) {
        
        markerLeft  = _markerImageIsDay? _drawableWidth/2.0 - MARKER_DAY_WIDTH/2.0 : _drawableWidth/2.0 - MARKER_IMAGE_SIZE/2.0;
        markerTop   = _drawableHeight - MARKER_LABEL_HEIGHT - MARKER_IMAGE_SIZE;
        markerWidth = _markerImageIsDay? MARKER_DAY_WIDTH : MARKER_IMAGE_SIZE;
        
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, markerWidth, MARKER_IMAGE_SIZE)];
        
        // 마커 그림
        markerImageSize = _markerImageIsDay? MARKER_DAY_WIDTH : _markerImageIsFlag?  MARKER_FLAG_SIZE : MARKER_IMAGE_SIZE;
        UIImage *markerImage = [UIImage imageNamed:_markerImageName];
        UIImageView *markerImageView = [[UIImageView alloc] initWithImage:markerImage];
        CGFloat imageViewLeft = markerWidth/2.0 - markerImageSize/2.0;
        CGFloat imageViewTop = MARKER_IMAGE_SIZE/2.0 - markerImageSize/2.0;
        markerImageView.frame = CGRectMake(imageViewLeft, imageViewTop, markerImageSize, markerImageSize);
        
        [_markerView addSubview:markerImageView];
        
        if (_markerImageIsDay) {
            
            // "몇 일차" 레이블
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:markerImageView.frame];
            dayLabel.text = [NSString stringWithFormat:@"%@일차", _day];
            dayLabel.textColor = [UIColor whiteColor];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            [dayLabel setFont:[UIFont systemFontOfSize:MARKER_LABEL_HEIGHT*0.8]];
            
            [_markerView addSubview: dayLabel];
            
        } else if (_markerImageIsFlag) {
            
            // 마커 테두리.
            UIBezierPath *rimPath = [UIBezierPath bezierPathWithOvalInRect:
                                     CGRectMake(imageViewLeft, imageViewTop, MARKER_FLAG_SIZE, MARKER_FLAG_SIZE)];
            CAShapeLayer *rimLayer = [CAShapeLayer layer];
            [rimLayer setFillColor:[UIColor clearColor].CGColor];
            [rimLayer setPath:rimPath.CGPath];
            [rimLayer setLineWidth:2];
            [rimLayer setStrokeColor:[UIColor blackColor].CGColor];
            [_markerView.layer addSublayer:rimLayer];
        }
        
    } else {
        
        markerLeft = _drawableWidth/2.0 - MARKER_IMAGE_SIZE/2.0;
        markerTop  = _drawableHeight - MARKER_LABEL_HEIGHT - MARKER_IMAGE_SIZE;
        
        _markerView = [[UIView alloc] initWithFrame:CGRectMake(markerLeft, markerTop, MARKER_IMAGE_SIZE, MARKER_IMAGE_SIZE)];
        
        CGFloat circleCenter = MARKER_IMAGE_SIZE/2.0 - MARKER_SIZE/2.0;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(circleCenter, circleCenter, MARKER_SIZE, MARKER_SIZE)];
        
        CAShapeLayer *markerLayer = [CAShapeLayer layer];
        [markerLayer setPath:circlePath.CGPath];
        
        [_markerView.layer addSublayer:markerLayer];
        
        if (_hasMarkerIcon) {
            [markerLayer setStrokeColor:[VOLO_COLOR CGColor]];
            [markerLayer setFillColor:[VOLO_COLOR CGColor]];
        } else {
            [markerLayer setStrokeColor:[LINE_COLOR CGColor]];
            [markerLayer setFillColor:[LINE_COLOR CGColor]];
        }
        [markerLayer setLineWidth:LINE_WIDTH];
    }
}

- (void) initializeMarkericonView {
    if (_markerIconView) return;
        
    CGFloat imageViewLeft, imageViewTop;
    
    UIImage *iconImage = [UIImage imageNamed:_iconImageName];
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    [iconImageView setBackgroundColor:[UIColor clearColor]];
    
    imageViewLeft = _drawableWidth/2 - MARKER_ICON_WIDTH/2.0;
    imageViewTop  = 0;
    iconImageView.frame = CGRectMake(imageViewLeft, imageViewTop, MARKER_ICON_WIDTH, MARKER_ICON_HEIGHT);
    
    _markerIconView = iconImageView;
}

- (void) initializeMarkerLabel {
    if (_markerLabel) return;
    _markerLabel = [[UILabel alloc] initWithFrame:
                    CGRectMake(-_drawableWidth/2.0, _drawableHeight - MARKER_LABEL_HEIGHT, _drawableWidth*2, MARKER_LABEL_HEIGHT)];
    _markerLabel.text = _place.name;
    _markerLabel.textAlignment = NSTextAlignmentCenter;
    _markerLabel.textColor = [UIColor grayColor];
    [_markerLabel setFont:[UIFont systemFontOfSize:MARKER_LABEL_HEIGHT]];
}

- (VLOPlace *) getPlace {
    return _place;
}



@end
