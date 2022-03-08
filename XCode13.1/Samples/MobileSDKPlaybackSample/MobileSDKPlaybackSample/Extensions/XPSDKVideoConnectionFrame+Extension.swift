//
//  XPSDKVideoConnectionFrame+Extension.swift
//  MobileSDKPlaybackSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation
import MIPSDKMobile

enum DataBaseError: Int {
    case none
    case start
    case end
    case error
}

extension XPSDKVideoConnectionFrame {
    private var hasChangedPlaybackEventsDbStartReached: Bool {
        return changedPlaybackEvents & XPSDKVideoConnectionFrameDatabaseStart.rawValue != 0
    }
    
    private var hasCurrentPlaybackEventsDbStartReached: Bool {
        return currentPlaybackEvents & XPSDKVideoConnectionFrameDatabaseStart.rawValue != 0
    }
    
    private var hasChangedPlaybackEventsDbEndReached: Bool {
        return changedPlaybackEvents & XPSDKVideoConnectionFrameDatabaseEnd.rawValue != 0
    }
    
    private var hasCurrentPlaybackEventsDbEndReached: Bool {
        return currentPlaybackEvents & XPSDKVideoConnectionFrameDatabaseEnd.rawValue != 0
    }
    
    private var hasChangedPlaybackEventsDbdError: Bool {
        return changedPlaybackEvents & XPSDKVideoConnectionFrameDatabaseError.rawValue != 0
    }
    
    private var hasCurrentPlaybackEventsDbdError: Bool {
        return currentPlaybackEvents & XPSDKVideoConnectionFrameDatabaseError.rawValue != 0
    }
    
    private var hasFramePlayStopped: Bool {
        return currentPlaybackEvents & XPSDKVideoConnectionFramePlayStopped.rawValue != 0
    }
    
    
    func checkFrameForDataBaseEdgeReached() -> DataBaseError {
        print("\(Constants.playbackStateLog)\(currentPlaybackEvents)")
        if (hasChangedPlaybackEventsDbStartReached || hasCurrentPlaybackEventsDbStartReached) && hasFramePlayStopped {
            return .start
        } else if (hasChangedPlaybackEventsDbEndReached || hasCurrentPlaybackEventsDbEndReached) && hasFramePlayStopped {
            return .end
        }
        
        return .none
    }
    
    func checkHeaderForDataBaseEdgeReached() -> DataBaseError {
        if hasChangedPlaybackEventsDbStartReached && hasCurrentPlaybackEventsDbStartReached && hasFramePlayStopped {
            return .start
        } else if hasChangedPlaybackEventsDbEndReached && hasCurrentPlaybackEventsDbEndReached && hasFramePlayStopped {
            return .end
        } else if hasChangedPlaybackEventsDbdError && hasCurrentPlaybackEventsDbdError {
            return .error
        }
        
        return .none
    }
}
