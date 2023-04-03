//
//  ResourceSettings.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

import Foundation

let kSettingsKeyProjectPath: String      = "ProjectPath"
let kSettingsKeyExcludeFolders: String   = "ExcludeFolders"
let kSettingsKeyResourceSuffixs: String  = "ResourceSuffixs"
let kSettingsKeyResourcePatterns: String = "ResourcePatterns"
let kSettingsKeyMatchSimilarName: String = "MatchSimilarName"


class ResourceSettings {
    
    static let shared: ResourceSettings = ResourceSettings()
    
    var projectPath: String? = ResourceSettings.getValue(for: kSettingsKeyProjectPath) as? String {
        didSet {
            ResourceSettings.set(value: projectPath, for: kSettingsKeyProjectPath)
        }
    }
    
    var excludeFolders: [String]? = ResourceSettings.getValue(for: kSettingsKeyExcludeFolders) as? [String] {
        didSet {
            ResourceSettings.set(value: excludeFolders, for: kSettingsKeyExcludeFolders)
        }
    }
    
    var resourceSuffixs: [String]? = ResourceSettings.getValue(for: kSettingsKeyResourceSuffixs) as? [String] {
        didSet {
            ResourceSettings.set(value: resourceSuffixs, for: kSettingsKeyResourceSuffixs)
        }
    }
    
    var resourcePatterns: [[String : Any]]? = ResourceSettings.getValue(for: kSettingsKeyResourcePatterns) as? [[String : Any]] {
        didSet {
            ResourceSettings.set(value: resourcePatterns, for: kSettingsKeyResourcePatterns)
        }
    }
    var matchSimilarName: Int? = ResourceSettings.getValue(for: kSettingsKeyMatchSimilarName) as? Int {
        didSet {
            ResourceSettings.set(value: matchSimilarName, for: kSettingsKeyMatchSimilarName)
        }
    }
    
    
}

extension ResourceSettings {
    func updateResourcePattern(atIndex: Int, withObj: Any?, forKey: String) {
        guard let obj = withObj else { return }

        let patterns: [[String : Any]] = self.resourcePatterns ?? []

        if patterns.count > 0 && atIndex < patterns.count {
            var pattern = patterns[atIndex]
            pattern[forKey] = obj
            self.resourcePatterns = patterns
        }
    }
    
    func addResourcePattern(_ pattern: [String : Any]?) {
        if let pattern = pattern {
            var patterns: [[String : Any]] = self.resourcePatterns ?? []
            patterns.insert(pattern, at: 0)
            self.resourcePatterns = patterns
        }
    }
    
    func removeResourcePattern(atIndex: Int) {
        var patterns: [[String : Any]] = self.resourcePatterns ?? []
        if patterns.count > 0 && atIndex < patterns.count {
            patterns.remove(at: atIndex)
            self.resourcePatterns = patterns
        }
    }
}

extension ResourceSettings {

    static func getValue(for key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func set(value: Any?, for key: String) {
        guard let value = value else { return }
        UserDefaults.standard.set(value, forKey: key)
//        UserDefaults.standard.synchronize()
    }
    
    static func removeValue(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        //        UserDefaults.standard.synchronize()
    }
    
}
