///
/// XPSDKUpstreamVideoConnection.h
///
/// The XPSDKUpstreamVideoConnection class handles uploading video frames to server
///

#import <Foundation/Foundation.h>
#import <MIPSDKMobile/XPSDKVideoConnection.h>
#import <MIPSDKMobile/XPSDKLocationData.h>
#import <UIKit/UIKit.h>

@protocol XPSDKUpstreamVideoConnectionDelegate;

/// The XPSDKUpstreamVideoConnection class handles uploading video frames to server
@interface XPSDKUpstreamVideoConnection : XPSDKVideoConnection {
    NSMutableURLRequest * request;
    
    unsigned int frameCounter;
}

/// Flag that indicates that connection is ready for more data
@property (nonatomic) BOOL readyForMoreData;

/// The compression of video
@property (nonatomic, assign) CGFloat compression;

/// Upstream connection delegate
@property (nonatomic, weak) id<XPSDKUpstreamVideoConnectionDelegate> upstreamEventsDelegate;

/// The location data
@property (nonatomic, strong) XPSDKLocationData* location;

/// Flag that indicates whether server supports location
@property (nonatomic, readonly) BOOL locationSupportedByServer;

/// The start time of frames per second
@property (nonatomic, strong) NSDate * fpsStartTime;

/// The index of video device
@property (nonatomic) NSUInteger videoDeviceIndex;

/// Flag that indicates if upstream is automatic
@property (nonatomic) BOOL automatic;

@property (nonatomic) float fps;

- (XPSDKVideoConnectionMethod) method;

///Designated initializer. Instances should only ne created by the main connection!
///@param mainConnection the main connection from which the video connection is derived.
///@param vid Video ID
- (id) initFromControlConnection:(XPSDKConnection *) mainConnection
                         videoID:(XPSDKVideoID) vid
       locationSupportedByServer:(BOOL) locSupported
                    imageQuality:(CGFloat) imageQuality;

///Open
- (void) open;

///Upload video data from buffer
///@param imageBuffer - the image buffer
///@param orientation - current device orientation
///@param videoDeviceIndex - indicator for back or front camera
- (void)uploadFromBuffer:(CVImageBufferRef)imageBuffer forCurrentOrientation:(UIInterfaceOrientation)orientation andVideoDeviceIndex:(NSUInteger) videoDeviceIndex;
- (void) enableLocation: (BOOL) enabled;

@end

///Upstream video connection delegate
@protocol XPSDKUpstreamVideoConnectionDelegate <NSObject>

@required
/// Called in case an error has occured during the upload
/// @param upstreamVideoConnection The upstream connection instance
/// @param error Brief description of the error. Most likely the error code will be an HTTP status code. You can also check the underlying error, if it exists for more information
///
/// Note that this method will ALWAYS be called on the main thread!
///
- (void) upstreamVideoConnection:(XPSDKUpstreamVideoConnection *) upstreamVideoConnection receivedError: (NSError *) error;

@optional
/// Called on each image upload.
/// @param upstreamVideoConnection Pointer to the upstream instance
/// @param compression Compression of the image (0..1)
/// @param byteLength Size of the image in bytes
/// @param fps Average frames per second
///
/// WARNING: This method will most likely be called on a thread, different from the main one!
///
- (void) upstreamVideoConnection:(XPSDKUpstreamVideoConnection *) upstreamVideoConnection uploadedFrameWithCompression: (float) compression size: (NSUInteger) byteLength fps: (NSUInteger) fps;

@end

