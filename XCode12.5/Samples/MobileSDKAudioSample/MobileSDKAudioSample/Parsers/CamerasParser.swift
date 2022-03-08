//
//  CamerasParser.swift
//  MobileSDKAudioSample
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
     * Recursive method for filtering from response only cameras, which have microphones
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
        responseItem.properties = propertiesForItem(item)
        responseItem.items = microphonesForCamera(item)
        
        if responseItem.identifier != nil {
            return .success(responseItem)
        } else {
            return .failure(NSError())
        }
    }

    private func propertiesForItem(_ item: Item) -> Any? {
        //We need to parse the properties for type Speaker only
        guard let properties = item[Constants.ResponseItem.properties] as? Item,
              let type = item[Constants.ResponseItem.type] as? String,
                 type == Constants.ResponseItem.microphone else { return nil }
        
        let propertiesResult = MicrophonePropertiesParser().parseData(properties)
        switch propertiesResult {
            case let .success(properties):
                return properties
            case .failure(_):
                print("Properties parsing error")
                return nil
        }
    }
    
    private func microphonesForCamera(_ item: Item) -> [MicrophoneData]? {
        guard let subitems = item[Constants.ResponseItem.items] as? Item else { return nil }
        
        var microphones = [MicrophoneData]()
        var allItems: [Item] = []
        let subitem = subitems[Constants.ResponseItem.item]
            
        // Convert it to array (in case if we have only one item)
        if let subitem = subitem as? Item {
            allItems = [subitem]
        } else if let subitem = subitem as? [Item] {
            allItems = subitem
        }
            
        for responseItem in allItems {
            if let type = responseItem[Constants.ResponseItem.type] as? String,
               type == Constants.ResponseItem.microphone {
                let result = parseItem(responseItem, type: MicrophoneData.self)
                switch result {
                    case let .success(speaker):
                        microphones.append(speaker)
                    case .failure(_):
                        print("Error parsing speakers")
                }
            }
        }
        
        return microphones.count > 0 ? microphones : nil
    }
}
