//
//  ContentView.swift
//  MetalXR
//
//  Created by Darien Johnson on 5/2/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        let isDeviceConnected = !runADBCommand(command: "devices -l").isEqual("List of devices attached\n\n")
        let isInstalled = runADBCommand(command: "shell pm list packages dev.peapods.metalxr").isEqual("package:dev.peapods.metalxr")
        NavigationStack {
            VStack {
                Text("MetalXR")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                Button(action: {
                    if(isInstalled) {
                        runADBCommandHeadless(command: "shell am start -n dev.peapods.metalxr")
                        // likely want to display a progress indicator and then move to a new view
                    } else {
                        // download and install the latest apk
                    }
                }) {
                    Text(isDeviceConnected ? isInstalled ? "Open MetalXR" : "Install MetalXR" : "No devices connected")
                }
                    .disabled(!isDeviceConnected)
                Text("MetalXR uses adb to install to devices.")
                    .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("MetalXR 0.0.1 by the PeaPodDevs")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
