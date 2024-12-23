//
//  GraphManager.swift
//  MapMe
//
//  Created by Crypto on 12/13/24.
//

import Foundation
import CoreLocation

class GraphManager {
    struct Node {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let type: String?
        let name: String?
    }

    struct Edge {
        let from: String
        let to: String
        let length: Double
        let coordinates: [CLLocationCoordinate2D]
    }

    // hold adjacency info: a list of connected nodes
    var adjacencyList: [String: [(node: String, weight: Double)]] = [:]
    
    var nodes: [String: Node] = [:]
    var edges: [Edge] = []
    
    /*
    init() {
        do {
            let loader = DataLoader()
            let loadedNodes = try loader.loadNodes(from: "level-1-nodes")
            let loadedEdges = try loader.loadEdges(from: "test-edges")

            // Populate dictionary from array
            for node in loadedNodes {
                nodes[node.id] = node
            }

            edges = loadedEdges
            
            // Once nodes and edges are loaded, build the graph
            buildGraph()
        } catch {
            print("Error loading data: \(error)")
        }
    }
     */
    
    func loadData(nodeFileName: String, edgeFileName: String) throws {
            let loader = DataLoader()
            let loadedNodes = try loader.loadNodes(from: nodeFileName)
            let loadedEdges = try loader.loadEdges(from: edgeFileName)

            nodes.removeAll()
            edges.removeAll()

            for node in loadedNodes {
                nodes[node.id] = node
            }

            edges = loadedEdges

            buildGraph()
        }
    
    private func buildGraph() {
            // Initialize adjacency list keys for each node
            for (id, _) in nodes {
                adjacencyList[id] = []
            }

            // Populate the adjacency list from edges
            for edge in edges {
                // Add the edge in one direction
                adjacencyList[edge.from]?.append((node: edge.to, weight: edge.length))
                
                // If undirected, add the reverse direction as well
                adjacencyList[edge.to]?.append((node: edge.from, weight: edge.length))
            }
        }
    
    // Test the graph
    func testGraphIntegrity() {
        // Ensure nodes are loaded
        print("Number of nodes: \(nodes.count)")
        for (id, node) in nodes {
            print("Node ID: \(id), Name: \(node.name ?? "N/A"), Type: \(node.type ?? "N/A"), Coordinates: \(node.coordinate)")
        }

        // Ensure edges are loaded
        print("Number of edges: \(edges.count)")
        for edge in edges {
            print("Edge from \(edge.from) to \(edge.to) with length \(edge.length)")
        }
        
        // Check adjacency list correctness
        if let neighbors = adjacencyList["110"] {
            print("Neighbors of node 110:")
            for neighbor in neighbors {
                print("- \(neighbor.node) (weight: \(neighbor.weight))")
            }
        } else {
            print("No neighbors for node 110 found.")
        }
    }

    func testNodeData() {
        for (id, node) in nodes {
            print("Node ID: \(id), Name: \(node.name ?? "nil"), Type: \(node.type ?? "nil")")
        }
    }
}

