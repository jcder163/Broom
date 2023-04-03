//
//  BroomManager.swift
//  Broom
//
//  Created by cocoa on 2023/3/30.
//

import Foundation

let kDefaultResourceSeparator  = "|"

class BroomManager {
    
    /// 配置资源后缀以｜分割
    /// - Parameter suffixs: 默认“imageset|jpg|gif|png|pdf”
    static func config(suffixs: String) {
        // 后缀转换成小写，方便后面使用
        var suffixs = suffixs.lowercased()
        // 去掉 空格 和 .
        suffixs = suffixs.replacingOccurrences(of: " ", with: "")
        suffixs = suffixs.replacingOccurrences(of: ".", with: "")
        // 配置需要扫描的后缀
        ResourceSettings.shared.resourceSuffixs = suffixs.components(separatedBy: kDefaultResourceSeparator)
        // 根据后缀创建正则
        let resourcePatterns = ResourceStringSeacher.shared.createDefaultResourcePatterns(with: ResourceSettings.shared.resourceSuffixs ?? [])
        // 配置扫描规则
        ResourceSettings.shared.resourcePatterns = resourcePatterns
    }
    
    /// 配置项目地址
    /// - Parameter projectPath: 项目路径
    static func config(projectPath: String) {
        ResourceSettings.shared.projectPath = projectPath
    }
    
    /// 配置忽略文件夹，多文件夹以“｜”分割
    /// - Parameter excludeFolders: 默认为空
    static func config(excludeFolders: String) {
        ResourceSettings.shared.excludeFolders = excludeFolders.components(separatedBy: kDefaultResourceSeparator)
    }
    
    /// 开始运行
    /// - Parameter enableSimilarMatch: 是否开启模糊匹配，暂时不推荐使用
    /// - Returns: 未使用的资源文件信息
    static func run(enableSimilarMatch: Bool = false) -> [ResourceFileInfo] {
        
        var unUsed: [ResourceFileInfo] = []
        // 重置扫描状态及产物
        ResourceFileSeacher.shared.reset()
        ResourceStringSeacher.shared.reset()
        //开始扫描文件列表
        let resourceInfos = ResourceFileSeacher.shared.start(with: ResourceSettings.shared.projectPath ?? "",
                                         excludeFolders:ResourceSettings.shared.excludeFolders ?? [],
                                         resourceSuffixs: ResourceSettings.shared.resourceSuffixs ?? [])
        // 开始扫描文件内容
        ResourceStringSeacher.shared.start(with: ResourceSettings.shared.projectPath ?? "",
                                           excludeFolders: ResourceSettings.shared.excludeFolders ?? [],
                                           resourceSuffixs:  ResourceSettings.shared.resourceSuffixs ?? [],
                                           resourcePatterns: ResourceSettings.shared.resourcePatterns ?? [])
        
        resourceInfos.forEach { element in
            
            let name = element.key
            if !ResourceStringSeacher.shared.containResource(withName: name) {
                // 如果开启模糊匹配，!enableSimilarMatch = false，则会判断是否命中后面条件，如果未开启模糊匹配，则直接检查是否有使用，模糊比配规则比较复杂，不建议开启
                if !enableSimilarMatch || !ResourceStringSeacher.shared.containsSimilarResource(withName: name) {
                
                    if !element.value.isDir || !self.usingRes(with: element.value) {
                        unUsed.append(element.value)
                    }
                    
                }
            }
        }
        
        return unUsed
    }
    
    
    static func usingRes(with resInfo: ResourceFileInfo) -> Bool {
        if !resInfo.isDir {
            return false
        }
        
        guard let paths = FileManager.default.subpaths(atPath: resInfo.path) else {
            return false
        }
       
        for fileNmae in paths {
            if !fileNmae.isImage {
                
            } else {
                let fileNameWithoutExt = fileNmae.removeResourceSuffix()
                
                if fileNameWithoutExt == resInfo.name {
                    return false
                }
                
                if ResourceStringSeacher.shared.containResource(withName: fileNameWithoutExt) {
                    return true
                }
            }
        }

        return false
    }

}
