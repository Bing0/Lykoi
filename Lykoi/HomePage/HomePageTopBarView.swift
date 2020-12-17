//
//  HomePageTopBarView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/24.
//

import SwiftUI

struct HomePageTopBarView: View {
    @ObservedObject var pdfDocViewModel: PDFDocViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                ScrollViewReader { value in
                    HStack {
                        ForEach(pdfDocViewModel.directoryContent.parentsInfo.indices, id: \.self) { index in
                            if index != 0 {
                                Image(systemName: "chevron.forward")
                            }
                            Text("\(pdfDocViewModel.directoryContent.parentsInfo[index].name)")
                                .font(.title2)
                                .onTapGesture {
                                    pdfDocViewModel.enter(newURL: pdfDocViewModel.directoryContent.parentsInfo[index].url)
                                }
                                .lineLimit(1)
                                .id(index == (pdfDocViewModel.directoryContent.parentsInfo.count - 1) ? "scrollToHere" : "B")
                                .onAppear {
                                    withAnimation {
                                        value.scrollTo("scrollToHere")
                                    }
                                }
                        }
                        Spacer()
                    }
                }
            }
                .background(Color.init("HomePageTopBarColor"))

            LyDividerView()
        }
    }
}

struct HomePageTopBarView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageTopBarView(pdfDocViewModel: PDFDocViewModel())
    }
}
