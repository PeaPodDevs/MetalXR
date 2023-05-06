//
//  InitialView.swift
//  MetalXR
//
//  Created by Darien Johnson on 5/2/23.
//

import SwiftUI
import Foundation

struct InitialView: View {
    let utils = Utilities()
    @State var showNetworkAlert = Bool()
    @State var hasNetworkConnection = Bool()
    @State var showFailureAlert = Bool()
    @State var operationIsActive = Bool()
    @State var isInstalled = Bool()
    @State var isDeviceConnected = Bool()
    @State var failureAlertMessage = String()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("MetalXR")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .task(checkForInternetConnection)
                    .task(beginScanningForDevices)
                    .task(checkForInstalledApp)
                    .task(utils.createAllDirectories)
                
                HStack {
                    if isDeviceConnected && isInstalled {
                        NavigationLink { HomeView() } label: { Text("Open MetalXR") }
                    } else {
                        Button(action: { downloadAndInstallAPK() }) {
                            Text(isDeviceConnected ? operationIsActive ? "Installing MetalXR" : "Install MetalXR" : "No devices connected")
                        }
                        .alert(isPresented: $showFailureAlert) {
                            Alert(
                                title: Text("MetalXR can't continue."),
                                message: Text("Something went wrong while we were getting things ready for you:\n\n" + failureAlertMessage)
                            )
                        }
                        .disabled(!isDeviceConnected || operationIsActive || !hasNetworkConnection)
                        if operationIsActive {
                            ProgressView()
                                .padding(.leading, 5)
                                .scaleEffect(0.5)
                        }
                    }
                }
            }
            .padding()
        }
#if DEBUG
        .navigationTitle("MetalXR (" + utils.version + "-" + utils.debugName + ")")
#else
        .navigationTitle("MetalXR")
#endif
    }
    
    @Sendable func checkForInstalledApp() async {
        isInstalled = utils.runADBCommand(command: "shell pm list packages dev.peapods.MetalXR",
                                          shouldPrintOutput: true).isEqual("package:dev.peapods.MetalXR\n")
        print(isInstalled ? "[Installer] MetalXR is already installed on device." :
                            "[Installer] MetalXR is not installed on device.")
    }
    
    @Sendable func beginScanningForDevices() async {
        while true {
            isDeviceConnected = !utils.runADBCommand(command: "devices -l",
                                                     shouldPrintOutput: false).isEqual("List of devices attached\n\n")
            sleep(1)
        }
    }
    
    @Sendable func checkForInternetConnection() async {
        showFailureAlert = !utils.isConnectedToNetwork()
        failureAlertMessage = "MetalXR requires an internet connection."
        hasNetworkConnection = !showNetworkAlert
    }
    
    func downloadAndInstallAPK() {
        // TODO: Split this up
        DispatchQueue.global(qos: .background).async {
            // Variable defining phase
            operationIsActive = true
            let packagePath = utils.appDataFolder?.appending(path: "metalxr.apk").path()
            let packagePathURL = URL(string: "file://" + packagePath!)
#if DEBUG
            let downloadURL = URL(string: "https://github.com/PeaPodDevs/MetalXRClient/releases/download/latest/dev.peapods.MetalXR.apk")
#else
            let downloadURL = URL(string: "https://github.com/PeaPodDevs/MetalXRClient/releases/download/" + utils.version + "/dev.peapods.MetalXR.apk")
#endif
            
            // Download phase
            var downloadFinished = Bool()
            
            if !FileManager().fileExists(atPath: packagePathURL!.path) {
                DispatchQueue.main.async {
                    utils.loadFile(url: downloadURL!, destinationURL: packagePathURL!, overwrite: false) { (path, error) in
                        if(error != nil) {
                            print("[Downloader] MetalXR failed to download, posting downloader error: " + error!.localizedDescription)
                            operationIsActive = false
                            showFailureAlert = true
                            failureAlertMessage = error!.localizedDescription
                        }
                        downloadFinished = true
                    }
                }
            } else {
                downloadFinished = true
            }
            
            while !downloadFinished && !FileManager().fileExists(atPath: packagePathURL!.path) {
                print("[Downloader] Waiting for completion.")
                sleep(1)
            }
            
            if operationIsActive && downloadFinished {
                // Install phase
                var result = String()
                DispatchQueue.main.async {
                    result = utils.runADBCommand(command: "install " + packagePath!, shouldPrintOutput: true)
                }
                
                
                while result.isEmpty {
                    print("[Installer] Waiting for completion.")
                    sleep(1)
                }
                
                if result.isEqual("Performing Streamed Install\nSuccess\n") {
                    print("[Installer] MetalXR was installed.")
                    operationIsActive = false
                    isInstalled = true
                } else {
                    print("[Installer] MetalXR failed to install, posting ADB output: " + result)
                    operationIsActive = false
                    showFailureAlert = true
                    failureAlertMessage = result
                }
            }
        }
    }
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}
