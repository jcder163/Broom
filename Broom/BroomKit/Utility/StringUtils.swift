//
//  StringUtils.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

import Foundation


let kSuffix2x: String = "@2x";
let kSuffix3x: String = "@3x";


extension String {
    
    /// 获取扩展名
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    /// 判断是否是图片
    var isImage: Bool {
        
        let suffixs = ["png", "jpg", "gif", "bmp", "pdf"]
        let pathExtension = self.pathExtension
        if pathExtension.isEmpty {
            return false
        } else {
            return suffixs.contains(self.pathExtension)
        }
    }
    
    func appending(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
    /// 移除后缀
    /// - Returns: 移除后缀后的string
    func removeResourceSuffix() -> String {
        return self.removeResourceSuffix(self.pathExtension)
    }
    
    /// 移除特定后缀
    /// - Parameter suffix: 后缀
    /// - Returns: 移除后缀后的string
    func removeResourceSuffix(_ suffix: String) -> String {
        var keyName = self
        if suffix.count > 0 && keyName.hasSuffix(suffix) {
            keyName = keyName.components(separatedBy: ".\(suffix)").first ?? keyName
        }
        if keyName.hasSuffix(kSuffix2x) {
            keyName = keyName.components(separatedBy: kSuffix2x).first ?? keyName
        } else if keyName.hasSuffix(kSuffix3x) {
            keyName = keyName.components(separatedBy: kSuffix3x).first ?? keyName
        }
        return keyName
    }
 
}
