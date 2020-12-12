//
//  PDFKitView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/29.
//

import SwiftUI


class PDFiumDocView: UIView {
    private var pdfDoc: PDFDoc?

    convenience init(url: URL) {
        self.init(frame: CGRect.zero)
        pdfDoc = PDFDoc(withURL: url)
        print(pdfDoc?.numberOfPages)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews \(frame)")
    }
}


struct PDFDocView: UIViewRepresentable {
    var url: URL
    var annotationInDoc: AnnotationInDoc?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PDFiumDocView {
        let pdfView = PDFiumDocView(url: url)

        return pdfView
    }

    func updateUIView(_ pdfView: PDFiumDocView, context: Context) {
    }

    class Coordinator: NSObject {
        var pdfKitView: PDFDocView

        private var annotationInDoc: AnnotationInDoc? {
            pdfKitView.annotationInDoc
        }

        init(_ parent: PDFDocView) {
            pdfKitView = parent
        }

    }
}
