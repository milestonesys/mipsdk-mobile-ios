//
//  ResponseItemParser.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

class ResponseItemParser : NSObject {
    func parseItem(_ item: Item) -> Result<ResponseItem, Error> {
        let responseItem = ResponseItem()
        
        responseItem.identifier = item[Constants.ResponseItem.Id] as? String
        responseItem.name = item[Constants.ResponseItem.name] as? String
        responseItem.type = item[Constants.ResponseItem.type] as? String
        responseItem.properties = propertiesForItem(item)
        responseItem.items = subitemsForItem(item)
        
        if responseItem.name != nil && responseItem.identifier != nil {
            return .success(responseItem)
        } else {
            return .failure(NSError())
        }
    }
}

// MARK: Helper methods
extension ResponseItemParser {
    private func propertiesForItem(_ item: Item) -> InvestigationProperties? {
        //We need to parse the properties for type Investigation only
        guard let properties = item[Constants.ResponseItem.properties] as? Item,
              let type = item[Constants.ResponseItem.type] as? String,
                 type == Constants.Parameters.investigation else { return nil }
        
        let propertiesResult = InvestigationPropertiesParser().parseData(properties)
        switch propertiesResult {
            case let .success(properties):
                return properties
            case .failure(_):
                print("Properties parsing error")
                return nil
        }
    }
    
    private func subitemsForItem(_ item: Item) -> [ResponseItem]? {
        guard let subitems = item[Constants.ResponseItem.items] as? Item else { return nil }
        
        var investigations = [ResponseItem]()
        var allItems:[Item] = []
        let subitem = subitems[Constants.ResponseItem.item]
            
        // Convert it to array (in case if we have only one item)
        if let subitem = subitem as? Item {
            allItems = [subitem]
        } else if let subitem = subitem as? [Item] {
            allItems = subitem
        }
            
        for responseItem in allItems {
            let result = parseItem(responseItem)
            switch result {
                case let .success(investigation):
                    investigations.append(investigation)
                case .failure(_):
                    print("Error parsing investigation")
            }
        }
        
        return investigations.count > 0 ? investigations : nil
    }
}
