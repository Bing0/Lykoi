//
//  DocumentListItemView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/24.
//

import SwiftUI

struct DocumentListItemView: View {
    var isDirectory: Bool
    var fileName:    String

    var body: some View {
        HStack {
            Image(systemName: isDirectory ? "folder" : "doc.richtext")
            Text("\(fileName)")
                .lineLimit(1)
            Spacer()
        }
    }
}

struct DocumentListItemView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentListItemView(isDirectory: true, fileName: "Test Folder")
            .previewLayout(.fixed(width: 300, height: 100))

        DocumentListItemView(isDirectory: false, fileName: "Test File.pdf")
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
