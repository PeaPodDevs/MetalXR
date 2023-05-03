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
        VStack {
            Button(action: {
                /* note from elli: wen pipe output from runADBCommand() */
                runADBCommand(command: "shell pm list packages org.peapods.metalxr")
                if () {
                    //download latest APK
                    runADBCommand(command: "shell install //pathtoapk")
                }
                else {
                    runADBCommand(command: "shell am start -n org.peapods.metalxr")
                }
            }) {
                Text("Click Me!")
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
