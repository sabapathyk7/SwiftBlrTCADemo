//
//  SwiftBlrTCADemoApp.swift
//  SwiftBlrTCADemo
//
//  Created by kanagasabapathy on 02/09/23.
//

import SwiftUI

@main
struct SwiftBlrTCADemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: .init(), reducer: {
                CurrencyConverter()
            }))
        }
    }
}
