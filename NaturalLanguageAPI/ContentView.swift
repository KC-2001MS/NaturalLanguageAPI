//
//  ContentView.swift
//  NaturalLanguageAPI
//
//  Created by 茅根啓介 on 2023/07/04.
//

import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    var body: some View {
        NavigationSplitView {
            InfoView(info: InfoObject(text: text))
        } detail: {
            TextEditor(text: $text)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
