//
//  TopBarView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/21.
//

import SwiftUI

struct TopBarView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String

    var body: some View {
        HStack {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                HStack {
                    Spacer()
                        .frame(width: 8)
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                    }
                }
                Spacer()
                    .frame(maxWidth: .infinity)
            }
            Text("\(title)")
                .lineLimit(1)
            Spacer()
                .frame(maxWidth: .infinity)
        }
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(title: "TTTTTTTTTest TTTTTTTTTTTTTTTTTittttttttttle")
    }
}
