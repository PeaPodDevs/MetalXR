//
//  InitialView.swift
//  MetalXR
//
//  Created by Darien Johnson on 5/2/23.
//

import SwiftUI
import Foundation

struct InitialView: View {
    @State var operationIsActive = Bool()
    @State var isDeviceConnected = !runADBCommand(command: "devices -l", shouldPrintOutput: false).isEqual("List of devices attached\n\n")
    @State var isInstalled = !runADBCommand(command: "shell pm list packages dev.peapods.MetalXR", shouldPrintOutput: true).isEmpty
    @State var count = Int()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Text("MetalXR")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                    .task(beginScanningForDevices)
                
                HStack {
                    if isInstalled {
                        NavigationLink { HomeView() } label: { Text("Open MetalXR") }
                    } else {
                        Button(action: {
                            DispatchQueue.global(qos: .background).async {
                                operationIsActive = true
                                
                                sleep(3)
                                
                                var isSuccess = Bool()
                                DispatchQueue.main.async {
                                    // TODO: Download
                                    isSuccess = runADBCommand(command: "install ~/Downloads/app_debug.apk",
                                                              shouldPrintOutput: true).isEqual("Performing Streamed Install\nSuccess\n")
                                }
                                
                                while(isSuccess == false) {
                                    sleep(1)
                                    print("[Installer] Waiting for confirmation.")
                                }
                                
                                operationIsActive = false
                                isInstalled = true
                            }
                            
                            
                        }) {
                            Text(isDeviceConnected ? operationIsActive ? "Installing MetalXR" : "Install MetalXR" : "No devices connected")
                        }
                        .disabled(!isDeviceConnected || operationIsActive)
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
        .navigationTitle("MetalXR 0.0.1 by the PeaPodDevs")
    }
    
    @Sendable private func beginScanningForDevices() async {
        while true {
            isDeviceConnected = !runADBCommand(command: "devices -l",
                                               shouldPrintOutput: false).isEqual("List of devices attached\n\n")
            sleep(1)
        }
    }
}

struct InitialView_Previews: PreviewProvider {
    static var previews: some View {
        InitialView()
    }
}
