//
//  ContentView.swift
//  TestSwiftUITeam
//
//  Created by Marcela Rodriguez on 4/16/21.
//

import SwiftUI
import HomeTurf

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    Text("Welcome")

                    NavigationLink(destination: HomeTurfWebView.init(auth0Service: TeamHomeTurfAuth0Service.init(), orientationUtility: TeamHomeTurfOrientationUtility.init())) {
                        Text("Go to HomeTurf")
                    }
                }
                .navigationBarTitle("Team App", displayMode: .inline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
