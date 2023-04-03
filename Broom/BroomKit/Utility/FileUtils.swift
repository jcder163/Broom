//
//  FileUtils.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

import Foundation

class FileUtils {
    
    
}
extension FileUtils {
    
    static func fileSize(at path: String, isDir: inout Bool) -> Int {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            isDir = attr[FileAttributeKey.type] as? FileAttributeType == FileAttributeType.typeDirectory
            if isDir {
                return folderSize(at: path)
            } else {
                let size = attr[FileAttributeKey.size] as? Int
                return size ?? 0
            }
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    static func folderSize(at path: String) -> Int {
        
        let fileEnumerator = FileManager.default.enumerator(atPath: path)
        
        let size = fileEnumerator?.directoryAttributes?[FileAttributeKey.size] as? Int

        return size ?? 0
    }
    
}
