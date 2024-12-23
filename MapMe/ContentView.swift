//
//  ContentView.swift
//  MapMe
//
//  Created by Crypto on 11/14/24.
//
/*
import SwiftUI
import MapboxMaps
import CoreLocation

struct ContentView: View {
    @State private var shouldRunAlgorithm = false
    
    var body: some View {
        Text("Testing graph...")
        /*
            .onAppear{
                testAlgorithm1()
            } */
        Button(action: {shouldRunAlgorithm = true}) {
            Text("Run Algorithm")
                .padding()
        }
        MapViewControllerWrapper(shouldRunAlgorithm: $shouldRunAlgorithm)
            .edgesIgnoringSafeArea(.all)
    }
    
    /* --older algorithm--
    func testAlgorithm() {
        // Suppose you have a GraphManager instance
        let graphManager = GraphManager()
        let pathfinder = Pathfinding()
        
        do {
            try graphManager.loadData(nodeFileName: "level-1-nodes", edgeFileName: "level-1-edges")
        } catch {
            print("Error loading data: \(error)")
            return
        }
        
        // test the dijktras
        if let result = pathfinder.dijkstra(graph: graphManager.adjacencyList, start: "171", goal: "149") {
            print("Shortest distance: \(result.distance)")
            print("Path: \(result.path)")
        } else {
            print("No path found.")
        }

    }
     */
    
    func testAlgorithm1() {
        // Suppose you have a GraphManager instance
        let graphManager = GraphManager()
        let pathfinder = Pathfinding()

        do {
            try graphManager.loadData(nodeFileName: "level-1-nodes", edgeFileName: "level-1-edges")
        } catch {
            print("Error loading data: \(error)")
            return
        }

        // test dijkstra's algorithm
        if let result = pathfinder.dijkstra(graph: graphManager.adjacencyList, start: "110", goal: "1161") {
            print("Shortest distance: \(result.distance)")
            print("Path: \(result.path)")

            // Convert the path (array of node IDs) into an array of Node objects
            var nodePath: [GraphManager.Node] = []
            for nodeId in result.path {
                if let node = graphManager.nodes[nodeId] {
                    nodePath.append(node)
                } else {
                    print("Warning: Node \(nodeId) not found in graphManager.nodes")
                }
            }

            // Now generate step-by-step instructions
            let instructionsGenerator = RouteInstructions()
            let instructions = instructionsGenerator.generateInstructions(for: nodePath)
            
            // Print the instructions
            for instruction in instructions {
                print(instruction)
            }

        } else {
            print("No path found.")
        }
    }

}

#Preview {
    ContentView()
}

*/
