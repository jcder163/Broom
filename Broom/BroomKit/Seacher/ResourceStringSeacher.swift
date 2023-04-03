//
//  ResourceStringSeacher.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

import Foundation


let kNotificationResourceStringQueryDone: String = "kNotificationResourceStringQueryDone"

class ResourceStringSeacher {
    
    static let shared: ResourceStringSeacher = ResourceStringSeacher()
    
    var resStringSet: Set<String> = []
    
    private var projectPath: String?
    
    private var resSuffixs: [String]?
    
    private var excludeFolders: [String]?
    
    private var fileSuffixToResourcePatterns: [String : ResourceStringPattern] = [:]
    
    private var isRunning: Bool = false

}

extension ResourceStringSeacher {
    
    func start(with projectPath: String, excludeFolders: [String], resourceSuffixs: [String], resourcePatterns: [[String : Any]]) {
        if self.isRunning {
            return
        }
        
        if projectPath.isEmpty == true {
            return
        }
        
        if resourcePatterns.isEmpty == true {
            return
        }
        
        self.isRunning = true
        self.projectPath = projectPath
        self.resSuffixs = resourceSuffixs
        self.excludeFolders = excludeFolders
        
        var fileSuffixToResourcePatterns: [String : ResourceStringPattern] = [:]
        
        resourcePatterns.forEach { resourcePattern in
            let pattern = ResourceStringPattern(dic: resourcePattern)
            if pattern.enable == true {
                fileSuffixToResourcePatterns[pattern.suffix?.lowercased() ?? ""] = pattern
            }
        }
        self.fileSuffixToResourcePatterns = fileSuffixToResourcePatterns
        self.runSearchTask()
    }
    
    func reset() {
        self.isRunning = false
        self.resStringSet.removeAll()
    }
    
    func containResource(withName: String) -> Bool {
        if (self.resStringSet.contains(withName) == true) {
            return true
        } else {
            if withName.pathExtension.count > 0 {
                let nameWithoutSuffix = withName.removeResourceSuffix()
                return self.resStringSet.contains(nameWithoutSuffix)
            }
        }
        return false
    }
    
    /// 模糊匹配，过滤有逻辑拼接的资源使用
    /// - Parameter withName: 资源名称，如rd_gua_seed6
    /// - Returns: 是否包含
    func containsSimilarResource(withName: String) -> Bool {
        let regexStr = "([-_]?\\d+)"
        guard let regexExpression = try? NSRegularExpression(pattern: regexStr, options: NSRegularExpression.Options.caseInsensitive) else { return false }
        
        let matchs = regexExpression.matches(in: withName, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: withName.count))

        if matchs.count == 1 {
            let checkingResult = matchs.first
            guard let numberRange = checkingResult?.range(at: 1) else {
                return false
            }
            
            var prefix: String = ""
            var suffix: String = ""
            
            var hasSamePrefix: Bool = false
            var hasSameSuffix: Bool = false
            
            if numberRange.location != 0 {
                prefix = String(withName.prefix(numberRange.location))
            } else {
                hasSamePrefix = true
            }
            
            if numberRange.location + numberRange.length < withName.count {
                suffix = String(withName.suffix(withName.count - numberRange.location - numberRange.length))
            } else {
                hasSameSuffix = true
            }
            
            for res in resStringSet {
                if hasSameSuffix && !hasSamePrefix {
                    if res.hasPrefix(prefix) {
                        return true
                    }
                }
                
                if hasSamePrefix && !hasSameSuffix {
                    if res.hasSuffix(suffix) {
                        return true
                    }
                }
                
                if !hasSameSuffix && !hasSamePrefix {
                    if res.hasSuffix(suffix) && res.hasPrefix(prefix) {
                        return true
                    }
                }
            }
        
        
            return false
            
        } else {
            return false
        }
        
    }
    
    func createDefaultResourcePatterns(with resSuffixs: [String]) -> [[String : Any]] {
        
        let enables = [true, true, true, true, true, true, true, true, true, true, true, true, true, true]
        let fileSuffixs = ["h", "m", "mm", "swift", "xib", "storyboard", "strings", "c", "cpp", "html", "js", "json", "plist", "css"]
        let cPattern = "([a-zA-Z0-9_-]*)\\.(\(resSuffixs.joined(separator: "|")))"
        let ojbcPattern = "@\"(.*?)\"" // @"imageNamed:@\"(.+)\"";//or: (imageNamed|contentOfFile):@\"(.*)\" //
        let xibPattern = "image name=\"(.+?)\"" // image name="xx"
        
        let filePatterns = [
            cPattern,    // .h
            ojbcPattern, // .m
            ojbcPattern, // .mm
            "\"(.*?)\"", // .swift
            xibPattern,  // .xib
            xibPattern,  // .storyboard
            "=\\s*\"(.*)\"\\s*;", // .strings
            cPattern,    // .c
            cPattern,    // .cpp
            "img\\s+src=[\"\'](.*?)[\"\']", // .html
            "[\"\']src[\"\'],\\s+[\"\'](.*?)[\"\']", // .js
            ":\\s*\"(.*?)\"", // .json
            ">(.*?)<",   // .plist
            cPattern     // .css
        ]
        
        let matchGroupIndexs = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        
        var patterns: [[String : Any]] = []
        
        fileSuffixs.enumerated().forEach { element in
            patterns.append([
                kPatternIdentifyEnable: enables[element.offset],
                kPatternIdentifySuffix: fileSuffixs[element.offset],
                kPatternIdentifyRegex: filePatterns[element.offset],
                kPatternIdentifyGroupIndex: matchGroupIndexs[element.offset]
            ])
        }
        
        return patterns
                
    }

}

extension ResourceStringSeacher {
    
    private func runSearchTask() {
        if let projectPath = projectPath {
            self.handleFiles(atDir: projectPath)
            self.isRunning = false
        } else {
            self.isRunning = false
        }
        
        
    }
    
    /// 解析文件夹中的文件
    /// - Parameter atDir: 文件夹路径
    private func handleFiles(atDir: String) {
        
        guard let files = try? FileManager.default.contentsOfDirectory(atPath: atDir), files.count > 0 else {
            return
        }
        
        files.forEach { file in
            // 过滤忽略掉的文件夹
            if file.hasPrefix(".") || self.excludeFolders?.contains(file) == true {
                
            } else {
                let tempPath = atDir.appending(pathComponent: file)
                if self.isDirectory(path: tempPath) {
                    self.handleFiles(atDir: tempPath)
                } else {
                    // 根据对应的拓展名，取出识别的正则，根据正则和文件路径扫描文件
                    let ext = file.pathExtension.lowercased()
                    if let resourcePattern = self.fileSuffixToResourcePatterns[ext] {
                        self.parseFile(atPath: tempPath, with: resourcePattern)
                    } else {
                    }
                }
            }
        }
        
    }
    
    /// 解析文件，获取对应文件中使用到的资源名称
    /// - Parameters:
    ///   - atPath: 文件路径
    ///   - resourcePattern: 正则匹配规则
    private func parseFile(atPath: String, with resourcePattern: ResourceStringPattern) {
        // 读取文件内容
        guard let content = try? String(contentsOfFile: atPath, encoding: .utf8) else { return }
        // 取出正则表达式
        guard let regex = resourcePattern.regex,
              let groupIndex = resourcePattern.groupIndex else { return }

        if regex.count > 0 && groupIndex >= 0 {
            // 构造使用到的资源名称集合
            let set = self.getMatchString(with: content, pattern: regex, groupIndex: groupIndex)
            self.resStringSet = resStringSet.union(set)
        }
        
    }
    
    /// 获取文件内容中使用到的资源名称
    /// - Parameters:
    ///   - content: 文件内容
    ///   - pattern: 文件对应的正则
    ///   - groupIndex: <#groupIndex description#>
    /// - Returns: 所有资源名称
    private func getMatchString(with content: String, pattern: String, groupIndex: Int) -> Set<String> {
        
        // 构造正则表达式iOS语法
        guard let regexExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            fatalError("pattern: \(pattern) 不合法")
        }
        // 匹配出所有字符串
        let matchs = regexExpression.matches(in: content, range: NSRange(location: 0, length: content.count))
        
        if matchs.count == 0 {
            return []
        } else {
            var set = Set<String>()
            // 解析出string（"xxx") 资源的使用必定要依赖构造出来的字符串
            matchs.forEach { checkingResult in
                
                if let sRange = Range(checkingResult.range(at: groupIndex), in: content) {
                    var res = String(content[sRange])
                    if (res.count > 0) {
                        // 根据匹配出来的字符串，确定名称
                        res = res.lastPathComponent
                        res = res.removeResourceSuffix()
                        set.insert(res)
                    }
                }
               
            }
            return set
        }
        
    }
    
    /// 判断文件是否是文件夹
    /// - Parameter path: 文件路径
    /// - Returns: isDirectory
    private func isDirectory(path: String) -> Bool {
        
        if ResourceFileSeacher.shared.isImageSet(folder: path) {
            return false
        }
        var isDirectory: ObjCBool = false

        FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
}
