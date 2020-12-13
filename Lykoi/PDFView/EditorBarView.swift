//
//  EditorBarView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/28.
//

import SwiftUI

struct EditorBarView: View {
    @Binding var editingMode: EditingMode

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
                    .frame(width: 8)
            Image(systemName: "hand.point.up")
                    .background(editingMode == .hand ? Color.gray : Color.clear)
                    .onTapGesture {
                        editingMode = .hand
                    }
            Image(systemName: "scribble")
                    .background(editingMode == .draw ? Color.gray : Color.clear)
                    .onTapGesture {
                        editingMode = .draw
                    }
            Image(systemName: "highlighter")
                    .background(editingMode == .highlight ? Color.gray : Color.clear)
                    .onTapGesture {
                        editingMode = .highlight
                    }
            Spacer()
        }
    }
}

struct EditorBarView_Previews: PreviewProvider {
    static var previews: some View {
        EditorBarView(editingMode: .constant(.draw))
    }
}
