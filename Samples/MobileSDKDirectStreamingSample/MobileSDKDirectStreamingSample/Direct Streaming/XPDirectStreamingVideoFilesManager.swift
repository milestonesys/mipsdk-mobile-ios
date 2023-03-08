//
//  XPCameraVideoViewData.swift
//  XProtect
//
//  Created by BGMAC-PPE-01 on 7.11.19.
//  Copyright © 2019 Milestone Systems A/S. All rights reserved.
//

import Foundation
import AVFoundation

class XPDirectStreamingVideoFilesManager : NSObject {
    
    private var videoChunksIncrement = 0;
    private let fileManager = FileManager.default
    private let cachesDirectoryPaths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
    
    func deleteLocalFileForPlayerItem(item: AVPlayerItem?) {
        guard let asset = item?.asset as? AVURLAsset else {
            return;
        }
        
        do {
            try fileManager.removeItem(atPath: asset.url.path)
        } catch let error as NSError {
            debugPrint("Could not delete file at url: \(error)")
        }
    }
    
    func deleteDirectoryWithName(directoryName: String?) {
        guard let directory = directoryName, let applicationDirectory = cachesDirectoryPaths.first as NSString? else {
            return
        }
        let filePath = applicationDirectory.appendingPathComponent(directory)
        
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            debugPrint("Could not delete directory: \(error)")
        }
    }
    
    func saveVideoData(data: NSData?, to directoryName: String?) -> URL? {
        guard let directory = directoryName, let videoData = data, let applicationDirectory = cachesDirectoryPaths.first as NSString? else {
            return nil
        }
        let directoryPath = applicationDirectory.appendingPathComponent(directory)
        
        do {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            debugPrint("Could not create direcory: \(error)")
        }
        
        let path = applicationDirectory.appendingPathComponent("\(directory)/\(XPDirectStreamingConstants.baseFileName)\(videoChunksIncrement)\(XPDirectStreamingConstants.fileExtension)")
        videoChunksIncrement += 1
        videoData.write(toFile: path, atomically: false)
        
        return URL(fileURLWithPath: path)
    }
}
