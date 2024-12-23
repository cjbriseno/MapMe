//
//  InstructionsView.swift
//  MapMe
//
//  Created by Crypto on 12/20/24.
//

import SwiftUI

struct InstructionsView: View {
    var instructions: [String]

    var body: some View {
        List(instructions, id: \.self) { instruction in
            Text(instruction)
        }
        .navigationTitle("Route Instructions")
    }
}

/*
#Preview {
    InstructionsView()
}
*/
