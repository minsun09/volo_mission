//  Marker.m


#import "VLOMarker.h"

@implementation VLOMarker
@synthesize x;
@synthesize y;

+ (CGFloat) distanceBetweenMarker1:(VLOMarker *)marker1 Marker2:(VLOMarker *)marker2 {
    CGFloat xDelta = marker2.x - marker1.x;
    CGFloat yDelta = marker2.y - marker1.y;
    CGFloat distance = sqrt(xDelta * xDelta + yDelta * yDelta);
    return distance;
}

- (UIView *) getMarkerView {
    // 마커 생성.
    UIImageView *markerImageView = [[UIImageView alloc]
                                    initWithImage: [UIImage imageNamed:MARKER_IMAGE_NAME]];
    CGFloat markerLeft = x - MARKER_SIZE/2;
    CGFloat markerTop = y - MARKER_SIZE;
    [markerImageView setFrame:CGRectMake(0, -MARKER_TRAVEL, MARKER_SIZE, MARKER_SIZE)];
    
    // 마커 레이블 생성.
    NSRange is_blank_name = [_name rangeOfString:@" "];
    NSMutableArray *label_arr=[NSMutableArray array];
    Boolean is_blank=FALSE;
    UILabel *markerLabel;
    
    
    if(is_blank_name.location!=NSNotFound)
    {
        NSArray *name_split = [_name componentsSeparatedByString:@" "];
        is_blank=TRUE;
        
        for(NSInteger i=0; i<name_split.count; i++)
        {
            markerLabel = [[UILabel alloc] initWithFrame:
                           CGRectMake(-MARKER_SIZE/2, -((name_split.count-i)*MARKER_LABEL_HEIGHT) -MARKER_TRAVEL, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
            markerLabel.text = [name_split objectAtIndex:i];
            markerLabel.font = [markerLabel.font fontWithSize:10];
            markerLabel.textAlignment = NSTextAlignmentCenter;
            
            [label_arr addObject:markerLabel];
            
        }
    }
    else
    {
        markerLabel = [[UILabel alloc] initWithFrame:CGRectMake(-MARKER_SIZE/2, -MARKER_LABEL_HEIGHT -MARKER_TRAVEL, MARKER_LABEL_WIDTH, MARKER_LABEL_HEIGHT)];
        markerLabel.text = _name;
        markerLabel.font = [markerLabel.font fontWithSize:10];
        markerLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    // 마커 레이블 + 마커를 담은 UIView 생성.
    UIView *markerView = [[UIView alloc] initWithFrame:
                          CGRectMake(markerLeft, markerTop, MARKER_SIZE, MARKER_SIZE + MARKER_LABEL_HEIGHT)];
    [markerView addSubview:markerImageView];
    
    if(is_blank)
    {
        for(NSInteger j=0; j<label_arr.count; j++)
        {
            [markerView addSubview:[label_arr objectAtIndex:j]];
        }
    }
    else
    {
        [markerView addSubview:markerLabel];
    }
    
    
    return markerView;
}

@end