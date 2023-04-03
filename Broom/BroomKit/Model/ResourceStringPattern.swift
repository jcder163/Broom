//
//  ResourceStringPattern.swift
//  Broom
//
//  Created by cocoa on 2023/3/30.
//

import Foundation

let kPatternIdentifyEnable     : String = "PatternEnable"
let kPatternIdentifySuffix     : String = "PatternSuffix"
let kPatternIdentifyRegex      : String = "PatternRegex"
let kPatternIdentifyGroupIndex : String = "PatternGroupIndex"

class ResourceStringPattern {
    
    var suffix: String?
    
    var enable: Bool = false
    
    var regex: String?
    
    var groupIndex: Int?

}

extension ResourceStringPattern {
    
    convenience init(dic: [String : Any]) {
        self.init()
        
        self.suffix = dic[kPatternIdentifySuffix] as? String
        self.enable = dic[kPatternIdentifyEnable] as? Bool ?? false
        self.regex = dic[kPatternIdentifyRegex] as? String
        self.groupIndex = dic[kPatternIdentifyGroupIndex] as? Int
        
    }
}
