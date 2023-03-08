/// XPSDKDownstreamVideoConnection.h
 
/// The XPSDKDownstreamVideoConnection class handles the entire delivery of frames from the server to the client. It is not responsible for sending any commands to the server - opening, closing, pausing and etc of a video stream is handled by the XPSDKVideoConnection class.

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import "XPSDKVideoConnectionFrame.h"
#import "XPSDKVideoConnection.h"

@class XPSDKConnection;
@class XPSDKResponse;
@protocol XPSDKVideoConnectionDelegate;

typedef enum {
    ///Live video stream from a camera
    XPSDKVideoConnectionSignalLive,
    ///Playback recordings from a recording server
    XPSDKVideoConnectionSignalPlayback,
    ///Request upstream connection
    XPSDKVideoConnectionSignalUpload
} /// Video connection signal type - live or playback
XPSDKVideoConnectionSignal;

/// XPSDKDownstreamVideoConnection
///
/// The XPSDKDownstreamVideoConnection class handles the entire delivery of frames from the server to the client. It is not responsible for sending any commands to the server - opening, closing, pausing and etc of a video stream is handled by the XPSDKVideoConnection class.
///
/// A video connection basically is a stream of frames from the server to the app. Each frame has a header with some optional fields and optional image (JPEG for the moment). The header may contain information about recording state, motion state, information about changes in the image, changes in the playback state and etc.
///
/// A video connection should operate with a delegate. It receives the events and images from the video connection and processes them in any way it wants - display them, change app state and etc.
///
/// The implementation of the video connection uses low-level streams & sockets instead of NSURLConnection. The reason is a limitation in the iOS - we cannot keep more than 6 opened connections to the same protocol/host/port. Which means if we start up to 6 cameras and we won't be able to send commands over the meta connection. Extra requests are being queued. Using sockets goes around that limitation, because it appears to be built in the NSURLConnection class.
///
/// The video connection class has very rudimentary support for parsing HTTP headers - just enough to detect if there is HTTP error from the server.
///
/// The video connection also supports restoring after broken data stream. When a frame is parsed its header is analyzed and if the video ID and other values in the header structure are wrong it enters a special "self repare" mode. When in that mode the incomming data is constantly analyzed to attempt to locate the next frame start. If is is found the class attempts to construct complete frame from that location in the data. If sucessfull resumes normal operation and notifies the delegate with the frame. All earlier that is simply discarded.
@interface XPSDKDownstreamVideoConnection : XPSDKVideoConnection <NSStreamDelegate> {
@private
    
    ///Method of connection
    XPSDKVideoConnectionMethod method;
    
    ///Type of connection signal
    XPSDKVideoConnectionSignal signal;
    
    ///The server address
    NSString * serverAddress;
    ///The server port
    NSUInteger serverPort;
    

    /// Data comming from the server
    NSInputStream * inputStream;
    
    /// Data we are sending to the server
    NSOutputStream * outputStream;
    
    /// Raw incoming data buffer
    uint8_t * buffer;
    
    /// Incoming data buffer
    NSMutableData * responseData;
    
    /// Camera resolution
    CGSize sourceSize;
    
    /// The ID of the camera
    XPSDKViewID cameraID;
    
    /// Flag - set to YES if the connection has received all HTTP headers and should begin searching for frames
    BOOL httpHeaderParsed;
    
    /// Flag, used by Pull mode connection - set to yes if the delegate has been informed of a received response (videoConnection:receivedResponse: callback)
    BOOL receivedResponseSentToDelegate;
    
    /// Keeps all http headers of the response
    NSMutableArray * headerLines;
    
    /// Used in case of broken data stream - keeps the video ID as NSData so we can search for in the incomming byte stream and possibly locate the next frame start
    NSData * searchForUUID;
}

/// Resolution of the camera. It is the delegate's responsibility to update this property on resolution change!
@property (nonatomic, assign) CGSize sourceSize;
/// ID of the camera the connection has been initiated to
@property (nonatomic, readonly) XPSDKViewID cameraID;
/// Video connection signal
@property (nonatomic, readonly) XPSDKVideoConnectionSignal signal;

/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsLive;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsPlayback;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsPTZ;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsPTZPresets;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsSequences;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsAviExports;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL supportsJpegExports;
/// Set by the main connection when creating the object. It should not be changed.
@property (nonatomic, assign) BOOL originalSizeRequested;
/// Server address
@property (nonatomic, readonly) NSString * serverAddress;
/// Server port
@property (nonatomic, readonly) NSUInteger serverPort;

/// Designated initializer. Instances should only ne created by the main connection!
/// @param mainConnection the main connection from which the video connection is derived.
/// @param camid ID of the camera
/// @param vid Video ID
/// @param connectionMethod The method of connection
/// @param signalType The Type of signal
/// @param size The resolution of the camera
- (id) initFromControlConnection:(XPSDKConnection *) mainConnection
                        cameraID:(XPSDKViewID) camid
                         videoID:(XPSDKVideoID) vid
                          method:(XPSDKVideoConnectionMethod) connectionMethod
                          signal:(XPSDKVideoConnectionSignal) signalType
                      sourceSize:(CGSize) size;


/// Designated initializer. Instances should be only created by the main connection!
/// @param serverURL Server url
/// @param camid ID of the camera
/// @param vid Video ID
/// @param connectionMethod The method of connection
/// @param signalType The Type of signal
/// @param size The resolution of the camera
- (id) initWithServerURL:(NSURL *) serverURL
                cameraID:(XPSDKViewID) camid
                 videoID:(XPSDKVideoID) vid
                  method:(XPSDKVideoConnectionMethod) connectionMethod
                  signal:(XPSDKVideoConnectionSignal) signalType
              sourceSize:(CGSize) size;

/// Opens the connection to the video server
- (void) open;

/// Allows changing the desired fps
- (void) setDesiredFps:(NSInteger)fps withSuccessHandler:(void(^)(XPSDKResponse *))successHandler andFailureHandler:(void(^)(NSError *))failureHandler;

@end

/// Video connection delegate protocol. Delegates of XPSDKVideoConnection must implement this protocol to receive notifications form the video connection - new images, recording/motion/playback state changes, etc
@protocol XPSDKVideoConnectionDelegate <NSObject>
@required

/// Notifies the delegate that the connection has received HTTP response upon opening the connection. Push mode video connections only call this method once - on the first request.
/// @param videoConnection - The video connection
/// @param headers List of headers received form the server
- (void) videoConnection: (XPSDKDownstreamVideoConnection *) videoConnection
        receivedResponse: (NSArray *) headers;

/// Notifies the delegate that the connection has received new frame. This is called even for frames that don't contain images. The reason is that the header may contain just recording/motion/playback events
/// @param videoConnection - The video connection
/// @param frame - The frame that has been received
- (void) videoConnection: (XPSDKDownstreamVideoConnection *) videoConnection
           receivedFrame: (XPSDKVideoConnectionFrame *) frame;

/// Notifies the delegate of a connection interruption. Usually network error
/// @param videoConnection - The video connection
/// @param error - The error
- (void) videoConnection: (XPSDKDownstreamVideoConnection *) videoConnection failedWithError:(NSError *) error;

/// Notifies the delegate the video connection has been closed.
/// @param videoConnection - The video connection
- (void) videoConnectionFinished: (XPSDKDownstreamVideoConnection *) videoConnection;

/// Use this when you only have received headers, but not something with them
/// @param videoConnection - The video connection
/// @param frame - the frame for which the headers are received
- (void) videoConnection: (XPSDKDownstreamVideoConnection *) videoConnection
 receivedHeadersForFrame: (XPSDKVideoConnectionFrame *)frame;

@end

