//
//  MetalXRApp.swift
//  MetalXR
//
//  Created by Darien Johnson on 5/2/23.
//

import SwiftUI
import Foundation

func runADBCommand(command: String) -> String {
    let task = Process();
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.currentDirectoryURL = Bundle.main.resourceURL?.appending(path: "adb-lib")
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "./adb ".appending(command)]
    task.standardInput = nil
    try! task.run()
    let data = pipe.fileHandleForReading.readToEnd()
    let output = String(data: data, encoding: .utf8)!
    task.launch()
    return String(output)!
}

@main
struct MetalXRApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
