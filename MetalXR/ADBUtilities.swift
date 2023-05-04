//
//  ADBUtilities.swift
//  MetalXR
//
//  Created by Eilionoir Tunnicliff on 5/3/23.
//

import Foundation

func launchADBServer() {
    /*
     Function to launch the ADB server
     */
    
    runADBCommandHeadless(command: "start-server", shouldPrintOutput: false)
    print("[ADB Server] Launched ADB server.")
}

func killADBServer() {
    /*
     Function to kill the ADB server
     */
    
    runADBCommandHeadless(command: "kill-server", shouldPrintOutput: false)
    print("[ADB Server] Killed ADB server.")
}

func runADBCommandHeadless(command: String, shouldPrintOutput: Bool) {
    /*
     Wrapper around runADBCommand() to log the result
     if a new String variable is not needed
     */
    
    let result = runADBCommand(command: command, shouldPrintOutput: shouldPrintOutput)
    if shouldPrintOutput { print("[ADB Command] Output of command: " + result) }
}

func runADBCommand(command: String, shouldPrintOutput: Bool) -> String {
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
    if shouldPrintOutput { print("[ADB Command] Ran command: '/bin/bash -c ./adb " + command + "'.") }
    return String(data: data.readDataToEndOfFile(), encoding: .utf8)!
}

func runCommandHeadless(command: String, shouldPrintOutput: Bool) {
    /*
     Wrapper around runCommand() to log the result
     if a new String variable is not needed
     */
    
    let result = runCommand(command: command, shouldPrintOutput: shouldPrintOutput)
    if shouldPrintOutput { print("[Command] Output of command: " + result) }
}

func runCommand(command: String, shouldPrintOutput: Bool) -> String {
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
    if shouldPrintOutput { print("[Command] Ran command: '/bin/bash -c " + command + "'.") }
    let data = pipe.fileHandleForReading
    return String(data: data.readDataToEndOfFile(), encoding: .utf8)!
}
