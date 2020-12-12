//
//  ContentView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/20.
//

import SwiftUI
import CoreData
import PDFKit

#if os(iOS)
import MobileCoreServices
#endif

struct ContentView: View {
    @ObservedObject var pdfDocViewModel = PDFDocViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HomePageTopBarView(pdfDocViewModel: pdfDocViewModel)
                DocumentListView(pdfDocViewModel: pdfDocViewModel)
                Rectangle()
                        .fill(Color.white.opacity(0.01))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                HomePageActionBar()
            }
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
                    .onDrop(of: [String(kUTTypePDF)], delegate: PDFDropDelegate(pdfDocViewModel: pdfDocViewModel))
        }
                .navigationViewStyle(StackNavigationViewStyle())

    }
}


struct PDFDropDelegate: DropDelegate {
    var pdfDocViewModel: PDFDocViewModel

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [String(kUTTypePDF)]) else {
            return false
        }

        let items = info.itemProviders(for: [String(kUTTypePDF)])
        for item in items {
            item.loadItem(forTypeIdentifier: kUTTypePDF as String) { file, _ in
                if let fileURL = file as? URL {
                    DispatchQueue.main.async {
                        pdfDocViewModel.copy(from: fileURL)
                    }
                }
            }
        }

        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .light)
        ContentView().environment(\.colorScheme, .dark)
    }
}
