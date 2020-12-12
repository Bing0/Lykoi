//
//  LyDividerView.swift
//  Lykoi
//
//  Created by Thomas on 2020/11/24.
//

import SwiftUI

struct LyDividerView: View {
    var body: some View {
        Rectangle()
                .frame(height: 1)
                .opacity(0.5)
    }
}

struct LyDividerView_Previews: PreviewProvider {
    static var previews: some View {
        LyDividerView()
    }
}
