//
//  ResourceFileSeacher.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

import Foundation

class ResourceFileSeacher {
    
    var isRunning: Bool = false
    
    var resNameInfoDict: [String : ResourceFileInfo] = [:]
    
    static let shared: ResourceFileSeacher = ResourceFileSeacher()
    
}

extension ResourceFileSeacher {
    
    func start(with projectPath: String, excludeFolders: [String], resourceSuffixs: [String]) -> [String : ResourceFileInfo] {
        if self.isRunning {
            return [:]
        }
        
        if projectPath.count == 0 || resourceSuffixs.count == 0 {
            return [:]
        }
        
        self.isRunning = true
        
        self.scanResourceFile(with: projectPath, excludeFolders: excludeFolders, resourceSuffixs: resourceSuffixs)
        
        return resNameInfoDict
        
    }
    
    private func scanResourceFile(with projectPath: String, excludeFolders: [String], resourceSuffixs: [String]) {
    
        let resPaths = self.resourceFiles(in: projectPath, excludeFolders: excludeFolders, resourceSuffixs: resourceSuffixs)
        var tempResNameInfoDict: [String : ResourceFileInfo] = [:]
        resPaths.forEach { path in
            let name = path.lastPathComponent
            if name.count > 0 {
                let keyName = name.removeResourceSuffix()
                if (tempResNameInfoDict[keyName] == nil) {
                    var isDir: Bool = false
                    let info = ResourceFileInfo(name: name,
                                                path: path,
                                                fileSize: FileUtils.fileSize(at: path,
                                                                             isDir: &isDir),
                                                isDir: isDir)
                    tempResNameInfoDict[keyName] = info
                }
            }
        }
        
        self.resNameInfoDict = tempResNameInfoDict
        self.isRunning = false
        
        
    }
    
    private func resourceFiles(in directory: String, excludeFolders: [String], resourceSuffixs: [String]) -> [String] {
        var resources: [String] = []
        resourceSuffixs.forEach { suffix in
            let pathList = self.search(directory: directory, excludeFolders: excludeFolders, fileType: suffix)
            pathList.forEach { path in
                if !self.isInImageSet(folder: path) && !path.contains(kSuffixBundle) {
                    resources.append(path)
                }
            }
        }
        return resources
    }
    
    private func search(directory: String, excludeFolders: [String], fileType: String) -> [String] {
        let task = Process()
        task.launchPath = "/usr/bin/find"
        var args: [String] = []
        args.append(directory)
        args.append("-name")
        args.append("*.\(fileType)")
        
        excludeFolders.forEach { folder in
            args.append("!")
            args.append("-path")
            args.append("*/\(folder)/*")
        }
        
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        
        do {
            if let data = try file.readToEnd() {
                let string = String(data: data, encoding: .utf8)
                return string?.components(separatedBy: "\n") ?? []
            } else {
                return []
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
    }
    
    private func search(directory: String, excludeFolders: [String], fileTypes: [String]) -> [String] {
        
        let task = Process()
        task.launchPath = "/usr/bin/find"
        var args: [String] = []
        args.append("-E")
        args.append(directory)
        args.append("-iregex")
        args.append(".*\\.(\(fileTypes.joined(separator: "|")))")
        
        excludeFolders.forEach { folder in
            args.append("!")
            args.append("-path")
            args.append("*/\(folder)/*")
        }
        
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        task.launch()
        
        do {
            if let data = try file.readToEnd() {
                let string = String(data: data, encoding: .utf8)
                return string?.components(separatedBy: "\n") ?? []
            } else {
                return []
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}

let kSuffixImageSet    = ".imageset"
let kSuffixLaunchImage = ".launchimage"
let kSuffixAppIcon     = ".appiconset"
let kSuffixBundle      = ".bundle"
let kSuffixPng         = ".png"

extension ResourceFileSeacher {
        
    func reset() {
        self.isRunning = false
        self.resNameInfoDict = [:]
    }
    
    func isImageSet(folder: String) -> Bool {
        if folder.hasSuffix(kSuffixImageSet) || folder.hasSuffix(kSuffixAppIcon) || folder.hasSuffix(kSuffixLaunchImage) {
            return true
        } else {
            return false
        }
    }
    
    func isInImageSet(folder: String) -> Bool {
        if !self.isImageSet(folder: folder) {
            if folder.contains(kSuffixImageSet) || folder.contains(kSuffixAppIcon) || folder.contains(kSuffixLaunchImage) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
