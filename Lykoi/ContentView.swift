//
//  ContentView.swift
//  Lykoi
//
//  Created by Thomas on 2020/12/11.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var pdfDocViewModel = PDFDocViewModel()

    var body: some View {
       Text("Hello World!")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
