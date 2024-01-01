//
//  SwiftUIView.swift
//  
//
//  Created by 戴藏龙 on 2023/4/21.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack {
            Image(systemName: "global")
            Text("Hello, World!")
        }
    }
}

struct S_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
