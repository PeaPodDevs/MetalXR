//
//  MetalXRApp.swift
//  MetalXR
//
//  Created by Darien Johnson on 5/2/23.
//

import SwiftUI
import Foundation

func runADBCommandHeadless(command: String) {
    /*
     Wrapper around runADBCommand() to log the result
     if a new String variable is not needed
     */
    
    let result = runADBCommand(command: command)
    print("[ADB Command] Output of command: " + result)
}

func runADBCommand(command: String) -> String {
    /*
     Function for ADB-specific commands
     Working directory is in MetalXR.app/Contents/Libs/adb-lib
     Uses Android platform-tools for commands
     */
    
    let task = Process();
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.currentDirectoryURL = Bundle.main.resourceURL?.appending(path: "adb-lib")
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "./adb ".appending(command)]
    task.standardInput = nil
    try! task.run()
    task.launch()
    let data = pipe.fileHandleForReading
    print("[ADB Command] Ran command: '/bin/bash -c ./adb " + command + "'.")
    return String(data: data.readDataToEndOfFile(), encoding: .utf8)!
}

func runCommandHeadless(command: String) {
    /*
     Wrapper around runCommand() to log the result
     if a new String variable is not needed
     */
    
    let result = runCommand(command: command)
    print("[Command] Output of command: " + result)
}

func runCommand(command: String) -> String {
    /*
     Function to run generic commands
     Working directory is the user's home folder
     */
    
    let task = Process();
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    task.standardInput = nil
    try! task.run()
    task.launch()
    print("[Command] Ran command: '/bin/bash -c " + command + "'.")
    let data = pipe.fileHandleForReading
    return String(data: data.readDataToEndOfFile(), encoding: .utf8)!
}

@main
struct MetalXRApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
