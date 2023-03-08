//
//  CamerasParser.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation
import MIPSDKMobile

class CamerasParser : NSObject {
    typealias Item = [String: Any]
    
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
     * Method for filtering from response only cameras, which have speakers
     */
    func parseData(_ data: Item) -> Result<[ResponseItem] , Error>? {
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
                  let itemId = item[Constants.ResponseItem.Id] as? String else { return nil }
            
            if type == Constants.ResponseItem.camera {
                let result = parseItem(item, type: ResponseItem.self)
                switch result {
                    case let .success(camera):
                        cameras.append(camera)
                        case .failure(_):
                        print("Error parsing cameras")
                }
            } else if type == Constants.ResponseItem.view ||
                      (type == Constants.ResponseItem.folder &&
                        itemId.caseInsensitiveCompare(Constants.allCamerasFolderId) == ComparisonResult.orderedSame) {
                //When the item is of type 'Folder' with the View ID of 'All Cameras' or of type 'View',
                //Parse its child items
                if let subItems = item[Constants.ResponseItem.items] as? Item {
                    return parseData(subItems)
                }
            }
        }
        
        return cameras.isEmpty ? .failure(NSError()) : .success(cameras)
    }
}

// MARK: Helper methods
extension CamerasParser {
    private func parseItem<T: ResponseItem>(_ item: Item, type: T.Type) -> Result<T , Error> {
        let responseItem = type.init()
        responseItem.identifier = item[Constants.ResponseItem.Id] as? String
        responseItem.name = item[Constants.ResponseItem.name] as? String
        responseItem.type = item[Constants.ResponseItem.type] as? String
        responseItem.properties = propertiesForItem(item)
        responseItem.items = speakersForCamera(item)
        
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
                 type == Constants.ResponseItem.speaker else { return nil }
        
        let propertiesResult = SpeakerPropertiesParser().parseData(properties)
        switch propertiesResult {
            case let .success(properties):
                return properties
            case .failure(_):
                print("Properties parsing error")
                return nil
        }
    }
    
    private func speakersForCamera(_ item: Item) -> [SpeakerData]? {
        guard let subitems = item[Constants.ResponseItem.items] as? Item else { return nil }
        
        var speakers = [SpeakerData]()
        var allItems:[Item] = []
        let subitem = subitems[Constants.ResponseItem.item]
            
        // Convert it to array (in case if we have only one item)
        if let subitem = subitem as? Item {
            allItems = [subitem]
        } else if let subitem = subitem as? [Item] {
            allItems = subitem
        }
            
        for responseItem in allItems {
            if let type = responseItem[Constants.ResponseItem.type] as? String,
               type == Constants.ResponseItem.speaker {
                let result = parseItem(responseItem, type: SpeakerData.self)
                switch result {
                    case let .success(speaker):
                        speakers.append(speaker)
                    case .failure(_):
                        print("Error parsing speakers")
                }
            }
        }
        
        return speakers.count > 0 ? speakers : nil
    }
}
