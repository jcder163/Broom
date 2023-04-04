//
//  main.swift
//  Broom
//
//  Created by cocoa on 2023/3/29.
//

let kDefaultResourceSuffixs = "imageset|jpg|gif|png|pdf|json|apng"

import Foundation
import ArgumentParser

@main
struct Broom: ParsableCommand {
    // Customize your command's help and subcommands by implementing the
    // `configuration` property.
    static var configuration = CommandConfiguration(
        // Optional abstracts and discussions are used for help output.
        abstract: " A simple tool to scan out unused resources of iOS projects ",

        // Commands can define a version for automatic '--version' support.
        version: "1.0.0",

        // Pass an array to `subcommands` to set up a nested tree of subcommands.
        // With language support for type-level introspection, this could be
        // provided by automatically finding nested `ParsableCommand` types.
        subcommands: [Scan.self, Config.self, Show.self],

        // A default subcommand, when provided, is automatically selected if a
        // subcommand is not given on the command line.
        defaultSubcommand: Scan.self)

}


extension Broom {
    

    struct Scan: ParsableCommand {
        static var configuration =
            CommandConfiguration(abstract: " Scan unused resources ")

        @Option(name: .shortAndLong, help: "Scan project path")
        var projectPath: String?
        
        @Option(name: .shortAndLong, help: "Resources extend, like png|pdf|json")
        var suffixs: String?
        
        @Option(name: .shortAndLong, help: "Exclude folders, like Pods|Others")
        var excludeFolders: String?
        
        @Option(name: .shortAndLong, help: "Output as json file")
        var outputPath: String?
        
        @Option(help: "Scan Project")
        var project: String?

        mutating func run() {
            guard let project = project else {
                fatalError("Project is Empty")
            }
            if let suffixs = suffixs {
                BroomManager.config(suffixs: suffixs, project: project)
            }
            
            if let projectPath = projectPath {
                BroomManager.config(projectPath: projectPath, project: project)
            }
            
            if let excludeFolders = excludeFolders {
                BroomManager.config(excludeFolders: excludeFolders, project: project)
            }
            
            let unused = BroomManager.run(project: project).compactMap { fileInfo -> [String : Any] in
                var info: [String : Any] = [:]
                info["file_name"] = fileInfo.name
                info["file_size"] = fileInfo.fileSize
                info["file_path"] = fileInfo.path
                
                return info
            }
            
            if let outputPath = outputPath {
                if FileManager.default.fileExists(atPath: outputPath) {
                    try? FileManager.default.removeItem(atPath: outputPath)
                } else {
                    
                }
                do {
                    
                    let data = try JSONSerialization.data(withJSONObject: unused,
                                                          options: .withoutEscapingSlashes)
                    FileManager.default.createFile(atPath: outputPath, contents: data)


                } catch let error {
                    fatalError(error.localizedDescription)
                }
        
                
            } else {
                do {
                    let data = try JSONSerialization.data(withJSONObject: unused as Any, options: .withoutEscapingSlashes)
                    let infoStr = String(data: data, encoding: String.Encoding.utf8)
                    print(infoStr ?? "")

                } catch let error {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }

    struct Config: ParsableCommand {
        
        static var configuration =
            CommandConfiguration(abstract: "Configure running parameters")
        
        @Option(name: .shortAndLong, help: "Scan project path")
        var projectPath: String?
        
        @Option(name: .shortAndLong, help: "Resources extend, like png|pdf|json")
        var suffixs: String?
        
        @Option(name: .shortAndLong, help: "Exclude folders, like Pods|Others")
        var excludeFolders: String?
        
        @Option(help: "Scan Project")
        var project: String?

        mutating func run() {
            
            guard let project = project else {
                fatalError("Project is Empty")
            }
            if let projectPath = projectPath {
                BroomManager.config(projectPath: projectPath, project: project)
            }
            
            if let suffixs = suffixs {
                BroomManager.config(suffixs: suffixs, project: project)
            }
            
            if let excludeFolders = excludeFolders {
                BroomManager.config(excludeFolders: excludeFolders, project: project)
            }
            
        }
    }
    
    struct Show: ParsableCommand {
        
        @Option(help: "Scan Project")
        var project: String?

        mutating func run() {
            
            guard let project = project else {
                fatalError("Project is Empty")
            }
            print("Project: \(project)")
            print("Project Path: \(ResourceSettings.shared.getProjectPath(about: project) ?? "")")
            print("Resource suffixs: \(ResourceSettings.shared.getResourceSuffixs(about: project) ?? [])")
            print("Exclude folders: \(ResourceSettings.shared.getExcludeFolders(about: project) ?? [])")
            
        }
    }
}
