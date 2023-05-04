//
//  HomeView.swift
//  MetalXR
//
//  Created by Eilionoir Tunnicliff on 5/3/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack (
            alignment: .leading,
            spacing: 10
        ) {
            Text("Hi.")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
            NavigationLink { InitialView() } label: { Text("back to welcome") }
                
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
