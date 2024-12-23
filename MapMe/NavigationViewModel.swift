//
//  NavigationViewModel.swift
//  MapMe
//
//  Created by Crypto on 12/21/24.
//

import SwiftUI
import CoreLocation

class NavigationViewModel: ObservableObject {
    @Published var allNodes: [GraphManager.Node] = []  // All available nodes for the current floor
    @Published var filteredNodes: [GraphManager.Node] = [] // Filter results
    @Published var searchQuery: String = "" {
        didSet {
            filterNodes()
        }
    }
    
    private let graphManager = GraphManager()

    func loadNodes(forFloor floor: Int) {
        do {
            let nodeFileName = "level-\(floor)-nodes"
            let edgeFileName = "level-\(floor)-edges"
            try graphManager.loadData(nodeFileName: nodeFileName, edgeFileName: edgeFileName)
            
            // Load nodes for the selected floor
            self.allNodes = Array(graphManager.nodes.values)
            self.filteredNodes = self.allNodes
        } catch {
            print("--Error loading nodes for floor \(floor): \(error)--")
        }
    }

    /// Filter nodes based on the current search query
    private func filterNodes() {
        guard !searchQuery.isEmpty else {
            filteredNodes = allNodes
            return
        }
        let lowerQuery = searchQuery.lowercased()
        
        filteredNodes = allNodes.filter { node in
            let idMatch = node.id.lowercased().contains(lowerQuery)
            let nameMatch = (node.name ?? "").lowercased().contains(lowerQuery)
            return idMatch || nameMatch
        }
    }
}


/* OLD
class NavigationViewModel: ObservableObject {
    @Published var allNodes: [GraphManager.Node] = []  // All available nodes
    @Published var filteredNodes: [GraphManager.Node] = [] // Filter results
    @Published var searchQuery: String = "" {
        didSet {
            filterNodes()
        }
    }
    
    init() {
        loadNodes()
    }
    
    private func loadNodes() {
        let graphManager = GraphManager()
        do {
            // We only need to load nodes here, not edges, for searching
            // If your DataLoader allows separate node/edge file loads, do that
            // or load everything if needed.
            try graphManager.loadData(nodeFileName: "level-1-nodes", edgeFileName: "level-1-edges")
            self.allNodes = Array(graphManager.nodes.values)
            self.filteredNodes = self.allNodes
        } catch {
            print("--Error loading nodes for search: \(error)--")
        }
    }
    
    /// Filter nodes based on the current searchQuery
    private func filterNodes() {
        guard !searchQuery.isEmpty else {
            filteredNodes = allNodes
            return
        }
        let lowerQuery = searchQuery.lowercased()
        
        // Simple substring matching on either node.id or node.name
        filteredNodes = allNodes.filter { node in
            let idMatch = node.id.lowercased().contains(lowerQuery)
            let nameMatch = (node.name ?? "").lowercased().contains(lowerQuery)
            return idMatch || nameMatch
        }
    }
}

*/
