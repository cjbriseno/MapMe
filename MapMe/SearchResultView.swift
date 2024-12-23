//
//  SearchResultView.swift
//  MapMe
//
//  Created by Crypto on 12/21/24.
//

import SwiftUI

struct SearchResultView: View {
    @ObservedObject var viewModel: NavigationViewModel
    
    let onNodesSelected: (String) -> Void
    
    var body: some View {
        VStack {
            TextField("Search a node or room...", text: $viewModel.searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if viewModel.filteredNodes.isEmpty {
                Text("No matches found")
                    .padding()
            } else {
                List(viewModel.filteredNodes, id: \.id) { node in
                    Button(action: {
                        onNodesSelected(node.id)
                    }) {
                        Text(nodeDisplay(node))
                    }
                }
                .listStyle(.inset)
            }
        }
        .navigationBarTitle("Select a Node", displayMode: .inline)
    }
    
    private func nodeDisplay(_ node: GraphManager.Node) -> String {
        let typeText = node.type ?? "Unkown"
        if let name = node.name, !name.isEmpty {
            return "\(typeText): \(name)"
        } else {
            return "\(node.id) (\(typeText))"
        }
    }
}
