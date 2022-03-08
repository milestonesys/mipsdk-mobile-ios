///
/// XPSDKLocationData.h

#import <Foundation/Foundation.h>

@class CLLocation;

///Location Data 
@interface XPSDKLocationData : NSObject
{
    struct {
        UInt32 headerSize;
        UInt32 version;
        UInt32 source;
        UInt32 reserved;
        UInt32 validFields;
        UInt32 longitude;
        UInt32 latitude;
        UInt32 altitude;
        UInt32 horizontalAccuracy;
        UInt32 verticalAccuracy;
        UInt32 speed;
        UInt32 azimuth;
    } header;
}

@property (readonly,nonatomic) NSInteger locationHeaderSize;
@property (readonly,atomic) BOOL hasValidLocation;

- (XPSDKLocationData *) init;
- (void) setLocation:(CLLocation *)location;
- (NSData *) locationHeaderData;

@end
