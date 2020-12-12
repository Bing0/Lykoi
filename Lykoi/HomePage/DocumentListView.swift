//
//  DocumentListView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/24.
//

import SwiftUI

struct DocumentListView: View {
    @ObservedObject var pdfDocViewModel: PDFDocViewModel

    var body: some View {
        VStack(spacing: 8) {
            ForEach(pdfDocViewModel.directoryContent.content, id: \.self) { contentURL in
                let fileName = contentURL.lastPathComponent
                let isDirectory = !contentURL.isFileURL

                if isDirectory {
                    HStack {
                        DocumentListItemView(isDirectory: isDirectory, fileName: fileName)
                                .onTapGesture {
                                    pdfDocViewModel.enter(newURL: contentURL)
                                }
                        Image(systemName: "slider.vertical.3")
                    }
                } else {
                    HStack {
                        NavigationLink(destination: PDFDocViewerView(url: contentURL)) {
                            DocumentListItemView(isDirectory: isDirectory, fileName: fileName)
                        }.buttonStyle(PlainButtonStyle())
                        Image(systemName: "slider.vertical.3")
                    }
                }
//                LyDividerView()
            }
        }
    }
}

struct DocumentListView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentListView(pdfDocViewModel: PDFDocViewModel())
    }
}
