/// XPSDKCameraPTZPreset.h
///

#import <Foundation/Foundation.h>

/// PTZ Preset has an identifier and a display name. Currently, we have to send the display name when we send commands to the server
@interface XPSDKCameraPTZPreset : NSObject

///Identifier of PTZ Preset
@property (nonatomic, strong) NSString * identifier;
///Display name of PTZ Preset
@property (nonatomic, strong) NSString * displayName;

@end
