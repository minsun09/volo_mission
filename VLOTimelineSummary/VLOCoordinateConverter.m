// VLOCoordinateConverter.m


#import "VLOCoordinateConverter.h"

@interface VLOCoordinateConverter()

@property (strong, nonatomic) NSMutableArray *distanceList;

@property () CGFloat actualWidth;
@property () CGFloat summaryWidth;
@property () CGFloat summaryHeight;
@property () CGFloat distanceSum;
@property () NSInteger maxMarkers;
@property () BOOL tooManyMarkers;

@end

@implementation VLOCoordinateConverter

- (id) initWithWidth:(CGFloat)width andHeight:(CGFloat)height {
    self = [super init];
    _summaryWidth = width;
    _summaryHeight = height;
    _actualWidth = _summaryWidth - HORIZONTAL_PADDING * 2;
    _maxMarkers = @(_actualWidth).intValue / @(MIN_DIST).intValue + 1;
    return self;
}

- (NSArray *) getCoordinates:(NSArray *)originalLogList {
    NSMutableArray *placeList = [[NSMutableArray alloc] init];
    NSMutableArray *dayList = [[NSMutableArray alloc] init];
    NSNumber *day;
   
    if (originalLogList.count < 1) {
        return [NSArray array];
    }
    
    for(NSInteger i = 0; i < originalLogList.count; i++) {
        VLOLog *log = [originalLogList objectAtIndex:i];
        
        if(log.type == VLOLogTypeDay) {
            VLODayLog *dayLog = (VLODayLog *)log;
            day = dayLog.day;
        }
        if(log.type == VLOLogTypeMap) {
            [placeList addObject:log.place];
            [dayList addObject:day];
        } else if(log.type == VLOLogTypeRoute) {
            for (VLOLog *node in ((VLORouteLog *)log).nodes) {
                [placeList addObject:node.place];
            }
            [dayList addObject:day];
        }
    }
    // 연속으로 중복되거나 불량한 인풋, 군집된 로케이션 정리
    NSArray *organized_placeList = [self sanitizeInput:placeList :dayList];

    // 각 마커의 x 좌표를 설정하기 위해 경도 분포를 확인합니다.
    [self initDistanceList:organized_placeList];
    
    NSInteger markerNum = organized_placeList.count;
    
    // 첫 VLOMarker의 좌표.
    CGFloat leftover = _actualWidth - @(MIN_DIST).intValue * (markerNum - 1);
    if (leftover < 0) {
        leftover = 0;
    }

    CGFloat xVariation = (organized_placeList.count == 1) ? 0 : leftover / 8.0;
    CGFloat leftmostX = @(MIN_DIST).intValue * (markerNum - 1) / 2 ;
    CGFloat adjustedLeftMostX = _summaryWidth/2 - leftmostX - xVariation/2;
    
    // VLOMarker 생성.
    NSMutableArray *markerList = [[NSMutableArray alloc] initWithCapacity:markerNum];
    CGFloat newX = adjustedLeftMostX;
    //NSInteger up = -1;
    
    for (NSInteger i = 0; i < organized_placeList.count; i++) {
        
        VLOPlace *place = [organized_placeList objectAtIndex:i];
        VLOMarker *newMarker = [[VLOMarker alloc] init];
        NSNumber *dayNum = [dayList objectAtIndex:i];
        
        if (i > 0) {
            // 오른쪽 여백이 안맞는 경우가 있어서 마지막 x좌표는 임의로 설정
            CGFloat horizontalVariation = xVariation * ([[_distanceList objectAtIndex:i-1] floatValue] / _distanceSum);
            newX += MIN_DIST + horizontalVariation;
        }
        
        newMarker.x = newX;
//        newMarker.y = _summaryHeight / 2 + up * Y_VARIATION;
        newMarker.y = _summaryHeight / 2;
        newMarker.name = place.name;
        newMarker.nameAbove = YES;
        newMarker.country = place.country;
        newMarker.day = dayNum;
        newMarker.dottedLeft = _tooManyMarkers && (i == _maxMarkers / 2);
        newMarker.dottedRight = _tooManyMarkers && (i == _maxMarkers / 2 - 1);
        //newMarker.color = [UIColor darkGrayColor];
        //up *= -1;
        
        // Random new marker color.
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
        newMarker.color = color;
        
        [markerList addObject:newMarker];
    }

    return markerList;
}

- (NSArray *) sanitizeInput:(NSArray *)placeList :(NSMutableArray *)dayList {
    
    NSMutableIndexSet *indicesToRemove = [NSMutableIndexSet indexSet];
    NSMutableArray *newPlaceList = [[NSMutableArray alloc] initWithArray:placeList copyItems:YES];
    NSInteger overlap_cnt = 0;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        
        BOOL sameLat = prevPlace.coordinates.latitude.floatValue == currPlace.coordinates.latitude.floatValue;
        BOOL sameLong = prevPlace.coordinates.longitude.floatValue == currPlace.coordinates.longitude.floatValue;
        
        // 중복되는 마커 검사. 중복되는 기준은 같은 coordinate.
        if (sameLat & sameLong) {
            overlap_cnt ++;
            [indicesToRemove addIndex:i];
        }

    }
    
    _tooManyMarkers = (placeList.count - overlap_cnt) > _maxMarkers;
    
    // 군집되는 경우
    if (_tooManyMarkers) {
        
        NSInteger trimIndexStart = _maxMarkers / 2;
        NSInteger overflow = placeList.count - _maxMarkers;
        
        [indicesToRemove addIndexesInRange:NSMakeRange(trimIndexStart, overflow)];
    }
    
    // 군집, 중복마커 제거
    [newPlaceList removeObjectsAtIndexes:indicesToRemove];
    [dayList removeObjectsAtIndexes:indicesToRemove];
    
    return newPlaceList;
}

- (void) initDistanceList:(NSArray *)placeList{
    _distanceList = [[NSMutableArray alloc] initWithCapacity:placeList.count-1];
    _distanceSum = 0;
    
    for (NSInteger i = 1; i < placeList.count; i++) {
        
        VLOPlace *prevPlace = [placeList objectAtIndex:i-1];
        VLOPlace *currPlace = [placeList objectAtIndex:i];
        CGFloat distance = [self distance:prevPlace:currPlace];
        _distanceSum += distance;
        [_distanceList addObject: @(distance)];
    }
    
}

- (CGFloat) distance:(VLOPlace *)from :(VLOPlace *)to {
    
    CGFloat latitudeDiff = [to.coordinates.latitude floatValue] - [from.coordinates.latitude floatValue];
    CGFloat longitudeDiff = [to.coordinates.longitude floatValue] - [from.coordinates.longitude floatValue];
    
    return sqrt(pow(latitudeDiff,2) + pow(longitudeDiff,2));
}


@end
















