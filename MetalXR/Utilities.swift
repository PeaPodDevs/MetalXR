//
//  Utilities.swift
//  MetalXR
//
//  Created by Eilionoir Tunnicliff on 5/3/23.
//

import Foundation
import SystemConfiguration


class Utilities : NSObject {
    
#if DEBUG
    public let debugName = "debug"
#else
    public let debugName = "release"
#endif
    
    public let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    public let aprilFools = "04/01"
    
    public let appDataFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    public let appPlatformFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "platform-tools")
    public let appLogFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "logs")
    
    // MARK: Downloader functions
    
    func loadFile(url: URL, destinationURL: URL, overwrite: Bool, completion: @escaping (String?, Error?) -> Void) {
        if FileManager().fileExists(atPath: destinationURL.path) {
            print("[Downloader] File already exists: \(destinationURL.path)")
            completion(destinationURL.path, nil)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: {
                data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if let _ = try? data.write(to: destinationURL, options: Data.WritingOptions.withoutOverwriting) {
                                    completion(destinationURL.path, error)
                                } else {
                                    completion(destinationURL.path, error)
                                    try! data.write(to: destinationURL, options: Data.WritingOptions.withoutOverwriting)
                                }
                            } else {
                                completion(destinationURL.path, error)
                            }
                        }
                    }
                } else {
                    completion(destinationURL.path, error)
                }
            })
            task.resume()
        }
    }
    
    // MARK: ADB functions
    
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
    
    // MARK: Generic command functions
    
    func runCommandHeadless(command: String, shouldPrintOutput: Bool, directory: String) {
        /*
         Wrapper around runCommand() to log the result
         if a new String variable is not needed
         */
        
        let result = runCommand(command: command, shouldPrintOutput: shouldPrintOutput, directory: directory)
        if shouldPrintOutput { print("[Command] Output of command: " + result) }
    }
    
    func runCommand(command: String, shouldPrintOutput: Bool, directory: String) -> String {
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
    
    // MARK: App setup functions
    @Sendable func createAllDirectories() async {
        /*
         Creates the directories needed for the app to run properly
         */
        try! FileManager().createDirectory(at: appDataFolder!, withIntermediateDirectories: true)
        print("[App Data] Ensured presence of app documents directory.")
        try! FileManager().createDirectory(at: appPlatformFolder!, withIntermediateDirectories: true)
        print("[App Data] Ensured presence of app platform-tools directory.")
        try! FileManager().createDirectory(at: appLogFolder!, withIntermediateDirectories: true)
        print("[App Data] Ensured presence of app logging directory.")
    }
    
    func isConnectedToNetwork() -> Bool {
        /*
         Function to see if the device is connected to the internet.
         */

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret
    }
}
