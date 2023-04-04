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
}

extension ResourceSettings {
    
    func setProjectPath(_ projectPath: String, for project: String) {
        var dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        dict[kSettingsKeyProjectPath] = projectPath
        ResourceSettings.set(value: dict, for: project)
        
    }
    func setExcludeFolders(_ excludeFolders: [String], for project: String) {
        var dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        dict[kSettingsKeyExcludeFolders] = excludeFolders
        ResourceSettings.set(value: dict, for: project)
        
    }
    func setResourceSuffixs(_ resourceSuffixs: [String], for project: String) {
        var dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        dict[kSettingsKeyResourceSuffixs] = resourceSuffixs
        ResourceSettings.set(value: dict, for: project)
    }
    
    func setResourcePatterns(_ resourcePatterns: [[String : Any]], for project: String) {
        var dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        dict[kSettingsKeyResourcePatterns] = resourcePatterns
        ResourceSettings.set(value: dict, for: project)
    }
    
    
    func getProjectPath(about project: String) -> String? {
        let dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        return dict[kSettingsKeyProjectPath] as? String
        
    }
    func getExcludeFolders(about project: String) -> [String]? {
        let dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        return dict[kSettingsKeyExcludeFolders] as? [String]
        
        
    }
    func getResourceSuffixs(about project: String) -> [String]? {
        let dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        return dict[kSettingsKeyResourceSuffixs] as? [String]
    }
    
    func getResourcePatterns(about project: String) -> [[String : Any]]? {
        let dict = ResourceSettings.getValue(for: project) as? [String : Any] ?? [:]
        return dict[kSettingsKeyResourcePatterns] as? [[String : Any]]
    }
}

extension ResourceSettings {

    static func getValue(for key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func set(value: Any?, for key: String) {
        guard let value = value else { return }
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func removeValue(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
}
