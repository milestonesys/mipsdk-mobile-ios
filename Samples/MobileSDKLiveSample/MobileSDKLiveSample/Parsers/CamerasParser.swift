//
//  CamerasParser.swift
//  MobileSDKLiveSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation
import MIPSDKMobile

typealias Item = [String: Any]

class CamerasParser: NSObject {
    var results: Result<[ResponseItem] , Error>?
    
    init(json: MIPSDKMobile.XPSDKResponse?) {
        super.init()
        
        guard let responseItems = json?.responseItems as? [Item],
              let firstItemDict = responseItems.first,
              let item = firstItemDict[Constants.ResponseItem.items] as? Item else {
            return
        }
        
        results = parseData(item)
    }
    
    /*
     * Recursive method for filtering from response all cameras
     */
    private func parseData(_ data: Item) -> Result<[ResponseItem] , Error>? {
        var allItems: [Item] = []
        var cameras: [ResponseItem] = []
        
        // Convert it to array (in case if we have only one item)
        let itemKey = Constants.ResponseItem.item
        if let itemToParse = data[itemKey] as? Item {
            //When there is only one item, then its type is NSDictionary, so to keep the consistency, we create an array of one item
            allItems = [itemToParse]
        } else if let itemsArr = data[itemKey] as? [Item] {
            //If the items are more than one, then they are an NSArray
            allItems = itemsArr
        }
        
        for item in allItems {
            guard let type = item[Constants.ResponseItem.type] as? String,
                  let itemId = item[Constants.ResponseItem.cameraId] as? String else { return nil }
            
            if type == Constants.ResponseItem.camera {
                //When an item of type 'Camera' is found, it is appended to the list of cameras to be displayed
                let result = parseItem(item, type: ResponseItem.self)
                switch result {
                    case let .success(camera):
                        cameras.append(camera)
                        case .failure(_):
                        print("Error parsing cameras")
                }
            } else if type == Constants.ResponseItem.folder && itemId.caseInsensitiveCompare(Constants.allCamerasFolderId) == ComparisonResult.orderedSame || type == Constants.ResponseItem.view, let subItem = item[Constants.ResponseItem.items] as? Item {
                //When the item is of type 'Folder' with the View ID of 'All Cameras' or of type 'View',
                //Parse its child items
                return parseData(subItem)
            }
        }
        
        return cameras.isEmpty ? .failure(NSError()) : .success(cameras)
    }
    
    private func parseItem<T: ResponseItem>(_ item: Item, type: T.Type) -> Result<T , Error> {
        let responseItem = type.init()
        responseItem.identifier = item[Constants.ResponseItem.cameraId] as? String
        responseItem.name = item[Constants.ResponseItem.cameraName] as? String
        responseItem.type = item[Constants.ResponseItem.type] as? String
        
        if responseItem.identifier != nil {
            return .success(responseItem)
        } else {
            return .failure(NSError())
        }
    }
}
