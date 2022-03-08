///
/// XPSDKVideoConnection.h
///
/// The XPSDKVideoConnection class represents the connection to video server
///

#import <Foundation/Foundation.h>

@protocol XPSDKVideoConnectionDelegate;
@class XPSDKConnection;

typedef enum {
    /// Push mode - frames are pushed by the server over an established HTTP conection. High frame rate but the server may drop images quality
    XPSDKVideoConnectionMethodPush,
    
    ///Pull mode - frames are requested by the client in a sequence, each in separate HTTP request. Lower frame rate but higher quality of images
    XPSDKVideoConnectionMethodPull
} /// Video connection image stream method
XPSDKVideoConnectionMethod;

/// Video ID - Currently a simple alias to NSString but defined as separate class for eventual future development (eg compare: methods or moving to GUIDs and etc
typedef NSString *XPSDKVideoID;

/// View ID
/// At the moment this is an alias to NSString but in the future some sort of GUID class may be better with probably some specific compare: methods
typedef NSString *XPSDKViewID;

/// This class manages an established connection and handles receiving and parsing frames. Do not create instances of that class directly. Instead call XPMobileSDK.requestStream to first prepare the connection to the camera. In the callback you will receive instance of the prepared VideoConnection object ready to be opened. Then set an observer object to receive frames, events and etc and just open the connection. Video connections cannot be reused. Once closed it cannot be reopened.
@interface XPSDKVideoConnection : NSObject {
    /// Video ID of the video connection. Use that to send commands over the meta connection
    XPSDKVideoID videoID;
    
    /// Each video connection keeps an instance of the main commands connection so it can
    /// send close and etc commands if needed and to update the network indicator
    XPSDKConnection *__weak metaConnection;
    
    ///Flag - set to YES if finished
    BOOL finished;
    
    ///The video connection delegate
    id <XPSDKVideoConnectionDelegate> __weak delegate;
}

/// Video ID of the video connection. Use that to send commands over the meta connection
@property (nonatomic, readonly) XPSDKVideoID videoID;
/// Each video connection keeps an instance of the main commands connection so it can
/// send close and etc commands if needed and to update the network indicator
@property (weak, nonatomic, readonly) XPSDKConnection * metaConnection;
/// Set to YES if the video connection has been started
@property (nonatomic, readonly, getter=isOpened) BOOL opened;
/// Delegate of the video connection
@property (nonatomic, weak) id<XPSDKVideoConnectionDelegate> delegate;
/// Method of the video connection
@property (nonatomic, readonly) XPSDKVideoConnectionMethod method;

///
///Designated initializer. Instances should only ne created by the main connection!
///@param mainConnection the main connection from which the video connection is derived.
///@param vid Video ID
- (id) initFromControlConnection:(XPSDKConnection *) mainConnection
                         videoID:(XPSDKVideoID) vid;

#pragma mark Methods for instance variable 'finished'

/// Closes the connection to the video server.
///
/// Should be implemented by the subclasses.
- (void) close;
@end
