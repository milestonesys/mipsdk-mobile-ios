///
/// XPSDKVideoConnectionFrame.h
///
/// The XPSDKVideoConnectionFrame represents a frame of video, sent over video connection.
/// A frame always contains a header, may contain one or more header extensions and may contain a single (JPEG encoded) image.
/// This class provides methods to analyze binary data and determine if it contains a complete and valid frame to be parsed. Use them
/// before attempting to init an instance.
///

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MIPSDKMobile/XPSDKVideoConnection.h>

typedef enum {
    ///Flag indicating a 'size' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionSize = 0x01,
    ///Flag indicating a 'live' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionLive = 0x02,
    ///Flag indicating a 'playback' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionPlayback = 0x04,
    ///Flag indicating a 'native data' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionNativeData = 0x08,
    ///Flag indicating a 'motion events' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionMotionEvents = 0x10,
    ///Flag indicating a 'location info' header extension of frame
    XPSDKVideoConnectionFrameHeaderLocationInfo = 0x20,
    ///Flag indicating a 'stream info' header extension of frame
    XPSDKVideoConnectionFrameHeaderStreamInfo = 0x40,
    ///Flag indicating a 'carousel' header extension of frame
    XPSDKVideoConnectionFrameHeaderExtensionCarousel = 0x80,
    ///Flag indicating a Carousel Info and Error in Audio Push Header Flag
    XPSDKVideoConnectionFrameHeaderExtensionDynamicInfo = 0x100,
    ///Flag indicating a Playback info
    XPSDKVideoConnectionFrameHeaderExtensionPlaybackInfo = 0x200,
    ///Flag indicating a 'all' header extension of frame
    XPSDKVideoConnectionFrameheaderAll = 0xFF
} ///Header extension flags of a video connection frame
XPSDKVideoConnectionFrameHeaderExtensionFlags;

typedef short unsigned int XPSDKVideoConnectionFrameHeaderExtensionMask;

typedef enum {
    ///Live frame flag indicating live feed
    XPSDKVideoConnectionFrameLiveFeed = 1,
    ///Live frame flag indicating motion
    XPSDKVideoConnectionFrameMotion = 2,
    ///Live frame flag indicating recording
    XPSDKVideoConnectionFrameRecording = 4,
    ///Live frame flag indicating notification
    XPSDKVideoConnectionFrameNotification = 8,
    ///Live frame flag indicating that connection is lost
    XPSDKVideoConnectionFrameCameraConnectionLost = 16,
    ///Live frame flag indicating database fail
    XPSDKVideoConnectionFrameDatabaseFail = 32,
    ///Live frame flag indicating that disk is full
    XPSDKVideoConnectionFrameDiskFull = 64,
    ///Live frame flag indicating live has stopped
    XPSDKVideoConnectionFrameClientLiveStopped = 128
} ///Flags for a frame containing live information
XPSDKVideoConnectionFrameLiveFlags;

typedef unsigned int XPSDKVideoConnectionFrameLiveEventsMask;

typedef enum {
    ///Playback frame flag indicating stopped playing
    XPSDKVideoConnectionFramePlayStopped =     0x1,
    ///Playback frame flag indicating forward playing
    XPSDKVideoConnectionFramePlayForward =     0x2,
    ///Playback frame flag indicating backward playing
    XPSDKVideoConnectionFramePlayBackward =    0x4,
    ///Playback frame flag indicating reached start of database
    XPSDKVideoConnectionFrameDatabaseStart =   0x10,
    ///Playback frame flag indicating reached end of database
    XPSDKVideoConnectionFrameDatabaseEnd =     0x20,
    ///Playback frame flag indicating error in database
    XPSDKVideoConnectionFrameDatabaseError =   0x40,
    ///Playback frame flag indicating no data in time range
    XPSDKVideoConnectionRangeNoData =   0x100,
    ///Playback frame flag indicating out of range frame
    XPSDKVideoConnectionFrameOutOfRange =   0x200
} ///Flags for a frame containing playback information
XPSDKVideoConnectionFramePlaybackFlags;

typedef unsigned int XPSDKVideoConnectionFramePlaybackEventsMask;

/// The XPSDKVideoConnectionFrame represents a frame of video, sent over video connection.
///
/// A frame always contains a header, may contain one or more header extensions and may contain a single (JPEG encoded) image.
///
/// This class provides methods to analyze binary data and determine if it contains a complete and valid frame to be parsed. Use them
/// before attempting to init an instance.
@interface XPSDKVideoConnectionFrame : NSObject {
@private
    /// ID of the video as specified in the frame's header
    /// :nodoc:
    XPSDKVideoID videoID;
    /// Timestamp of the frame
    /// :nodoc:
    NSDate * timestamp;
    
    /// :nodoc:
    /// The timestamp in miliseconds
    long long timestamp_ms;
    
    /// :nodoc:
    /// Index of the frame (not used at the moment)
    NSUInteger frameNumber;
    
    /// :nodoc:
    ///The flags of frame's header extension
    XPSDKVideoConnectionFrameHeaderExtensionMask headerExtensionFlags;
    
    /// :nodoc:
    /// The resolution of the camera
    CGSize sourceSize;
    
    /// :nodoc:
    /// This is not a crop rectangle and is improperly defined as UIEdgeInsets. top/left correspond to the offset from the top and left edge of the camera but bottom and right are actually the coordinates of the bottom right corner of the crop area.
    UIEdgeInsets sourceCrop;
    
    /// :nodoc:
    /// The dimensions of the image we (will) receive
    CGSize destinationSize;
    
    /// :nodoc:
    /// Resampling tag
    NSUInteger resamplingTag;
    
    /// :nodoc:
    /// Current live events property comes in pair with changed live events if the frame contains the Live header extension. Both properties contain a mask of XPSDKVideoConnectionFrameLiveFlags.
    XPSDKVideoConnectionFrameLiveEventsMask currentLiveEvents;
    
    /// :nodoc:
    /// Changed live events property comes in pair with changed live events if the frame contains the Live header extension. Both properties contain a mask of XPSDKVideoConnectionFrameLiveFlags.
    XPSDKVideoConnectionFrameLiveEventsMask changedLiveEvents;
    
    /// :nodoc:
    /// Indicates that live header extension contains stream info
    XPSDKVideoConnectionFrameLiveEventsMask hasFrameStreamInfo;
    
    /// :nodoc:
    /// Current live events property comes in pair with changed playback events if the frame contains the Playback header extension. Both properties contain a mask of XPSDKVideoConnectionFramePlaybackFlags.
    XPSDKVideoConnectionFramePlaybackEventsMask currentPlaybackEvents;
    
    /// :nodoc:
    /// Changed live events property comes in pair with current playback events if the frame contains the Playback header extension. Both properties contain a mask of XPSDKVideoConnectionFramePlaybackFlags.
    XPSDKVideoConnectionFramePlaybackEventsMask changedPlaybackEvents;
    
    /// :nodoc:
    /// Indicates that playback header extension contains stream info
    XPSDKVideoConnectionFramePlaybackEventsMask headerStreamInfo;
    
    /// :nodoc:
    /// Indicates time between frames in ms (only for direct streaming)
    NSUInteger timeBetweenFrames;
    
    /// :nodoc:
    /// Four letter data type (e.g. H264, JPEG) of the underlying raw stream
    NSString *streamInfoDataType;
    
    /// :nodoc:
    /// Image, if any, sent with the frame
    UIImage * image;
    
    /// :nodoc:
    /// Raw video data without headers
    NSData *videoData;
}

/// ID of the video as specified in the frame's header
@property (nonatomic, readonly) XPSDKVideoID videoID;

/// Raw video data without headers
@property (nonatomic, readonly) NSData *videoData;

/// Timestamp of the frame
@property (nonatomic) NSDate * timestamp;
/// Index of the frame (not used at the moment)
@property (nonatomic, readonly) NSUInteger frameNumber;
/// Timestamp of the frame (in ms)
@property (nonatomic, readonly) long long timestamp_ms;

#pragma mark Header extension flags

/// Flag indicating whether the frame contains the size header extension
///
///If a frame contains size information (header extension) we get several properties - resolution of the camera, what region is cropped and sent and what are the dimensions of the image we will receive. This is not sent with every frame we get, but only if any of these change (say after changeStream commands).
@property (nonatomic, readonly) BOOL hasSizeInformation;

/// Flag indicating whether the frame contains the playback header extension
///
/// If the frame contains the Live header extension, current and changed live events come in pair.
@property (nonatomic, readonly) BOOL hasLiveInformation;

/// Flag indicating whether the frame contains the playback header extension
///
/// If the frame contains the Playback header extension, current and changed live events come in pair.
@property (nonatomic, readonly) BOOL hasPlaybackInformation;

/// Flag indicating whether the frame contains the stream info header extension
@property (nonatomic, readonly) BOOL hasStreamInfoHeaderInformation;

/// The resolution of the camera
@property (nonatomic, readonly) CGSize sourceSize;

/// This is not a crop rectangle and is improperly defined as UIEdgeInsets. top/left correspond to the offset from the top and left edge of the camera but bottom and right are actually the coordinates of the bottom right corner of the crop area.
@property (nonatomic, readonly) UIEdgeInsets sourceCrop;

/// The dimensions of the image we (will) receive
@property (nonatomic, readonly) CGSize destinationSize;

/// The crop rectangle as proper rectangle - top left is the top left corner and width/height is width/height - both in camera's resolution
@property (nonatomic, readonly) CGRect sourceRect;

/// Resampling tag
@property (nonatomic, readonly) NSUInteger resamplingTag;

/// Current live events property comes in pair with changed live events if the frame contains the Live header extension. Both properties contain a mask of XPSDKVideoConnectionFrameLiveFlags.
@property (nonatomic, readonly) XPSDKVideoConnectionFrameLiveEventsMask currentLiveEvents;

/// Changed live events property comes in pair with changed live events if the frame contains the Live header extension. Both properties contain a mask of XPSDKVideoConnectionFrameLiveFlags.
@property (nonatomic, readonly) XPSDKVideoConnectionFrameLiveEventsMask changedLiveEvents;

/// Current live events property comes in pair with changed playback events if the frame contains the Playback header extension. Both properties contain a mask of XPSDKVideoConnectionFramePlaybackFlags.
@property (nonatomic, readonly) XPSDKVideoConnectionFramePlaybackEventsMask currentPlaybackEvents;

/// Changed live events property comes in pair with current playback events if the frame contains the Playback header extension. Both properties contain a mask of XPSDKVideoConnectionFramePlaybackFlags.
@property (nonatomic, readonly) XPSDKVideoConnectionFramePlaybackEventsMask changedPlaybackEvents;

/// Indicates time between frames in ms (only for direct streaming)
@property (nonatomic, readonly) NSUInteger timeBetweenFrames;

/// Four letter data type (e.g. H264, JPEG) of the underlying raw stream
@property (nonatomic, readonly) NSString *streamInfoDataType;

/// number of frames in the current fragment (only for direct streaming)
@property (nonatomic, readonly) NSUInteger frameCount;

/// time when the request was sent
@property (nonatomic, readonly) NSDate *requestedTime;

/// Image, if any, sent with the frame
@property (nonatomic, strong) UIImage * image;

/// Checks a byte stream and verifies if we have enough data in it to construct a frame object
/// @param data The byte array to check
/// @return Yes if the data contains enough data to parse the base header, the header contains a valid frame length and that there is enough data to construct a frame with that length.
///
/// Note: if the base frame header contains an unnaturally long expected frame length (say 1GB) this method will return NO if the data is less than that size. It could be good idea to have some limit on how large a frame may be so we can detect such potentially invalid headers and discard that data, sending the video connection in "self repair" mode
+ (BOOL) dataContainsCompleteFrame:(NSData *) data;

/// Checks a byte stream and verifies if the data contains the correct video ID
/// @param data The data to be checked
/// @param videoID The video ID to check for
/// @return Yes if the data seems to contain a valid frame
+ (BOOL) data:(NSData *) data matchesVideoID: (NSString *) videoID;

/// Designated initializer - c reates a new frame object from a byte stream
/// @param data input data
- (id) initWithData: (NSData *) data;

@end
