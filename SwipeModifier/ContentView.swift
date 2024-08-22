//
//  ContentView.swift
//  SwipeModifier
//
//  Created by Lloyd Sargent on 8/22/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .frame(width:600, height: 400)
        .onSwipe { event in
            switch event.direction {
                case .up:
                    print("up")
                case .down:
                    print("down")
                case .left:
                    print("left")
                case .right:
                    print("right")
                default:
                    print("nothing")
            }
        }
    }
    
}

#Preview {
    ContentView()
}
