//
//  PDFKitView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/20.
//

import SwiftUI

struct PDFDocHostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    private var docRequest: FetchRequest<AnnotationInDoc>
    private var annotationInDoc: FetchedResults<AnnotationInDoc> {
        docRequest.wrappedValue
    }

    @State var xOffset: CGFloat = 0
    @State var editingMode: EditingMode = .hand

    var url: URL

    init(url: URL) {
        self.url = url
        docRequest = FetchRequest(
                entity: AnnotationInDoc.entity(),
                sortDescriptors: [],
                predicate: NSPredicate(format: "%K == %@", #keyPath(AnnotationInDoc.relativePath), url.relativeToHome()),
                animation: .default)
    }

    var returnGesture: some Gesture {
        DragGesture()
                .onChanged { value in
                    if (value.startLocation.x < 20) {
                        DispatchQueue.main.async {
                            xOffset = value.translation.width
                        }
                    }
                }
                .onEnded { value in
                    if (value.startLocation.x < 20 && value.predictedEndLocation.x > 100) {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        DispatchQueue.main.async {
                            withAnimation {
                                xOffset = 0
                            }
                        }
                    }
                }
    }

    var body: some View {
        VStack {
            TopBarView(title: url.lastPathComponent)
            EditorBarView(editingMode: $editingMode)
                    .offset(x: xOffset, y: 0)
            PDFDocViewController(url: url, annotationInDoc: annotationInDoc.count == 0 ? nil : annotationInDoc[0], editingMode: $editingMode)
                    .offset(x: xOffset, y: 0)
        }
                .navigationBarTitle("")
                .navigationBarHidden(true)
//                .gesture(returnGesture)
                .onAppear {
                    if annotationInDoc.count == 0 {
                        let doc = AnnotationInDoc(context: viewContext)
                        doc.relativePath = url.relativeToHome()
                        doc.isiCloud = false
                        do {
                            try viewContext.save()
                        } catch {
                            print("WTF! \(error)")
                        }
                    }
                }
    }
}

struct PDFDocViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let documentURL = Bundle.main.url(forResource: "sample", withExtension: "pdf")!
        PDFDocHostView(url: documentURL)
        PDFDocHostView(url: documentURL)
                .environment(\.colorScheme, .dark)
    }
}
