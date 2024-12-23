//
//  CustomStyleView.swift
//  MapMe
//
//  Created by Crypto on 12/18/24.
//

import SwiftUI
import MapboxMaps

struct CustomStyleView: View {
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var currentRouteInstructions: [String] = []
    @State private var startNode: String = ""
    @State private var endNode: String = ""
    @State private var mapboxMap: MapboxMap? // store MapboxMap instance
    @State private var selectedFloor: Int = 1
    @State private var currentStepIndex: Int = 0
    
    @StateObject private var nodeSearchModel = NavigationViewModel()
    
    var customStyle: MapStyle {
        if let styleURI = StyleURI(rawValue: "mapbox://styles/fr3shtricks/cm3w53d4700c601rdgzjp53h9") {
            return MapStyle(uri: styleURI)
        } else {
            print("--Failed to load custom style, falling back to streets style--")
            return .streets
        }
    }
    
    var body: some View {
      NavigationView {
        ZStack {
          MapReader { proxy in
            Map()
              .mapStyle(customStyle)
              .onAppear {  // older implementation
                if mapboxMap == nil {  // Store the map instance on first appearance
                  mapboxMap = proxy.map
                  if let map = proxy.map {
                    configureUnderlyingMap(map)
                    addPuck(to: map)
                    //applyFloorVisibility(for: map, floor: selectedFloor)
                    applyGroupVisibility(for: map, group: "level-\(selectedFloor)")
                  } else {
                    print("--MapReader proxy.map is nil.--")
                  }
                }
              }
          }
          .ignoresSafeArea()

          // --UI controls--
          VStack {
            HStack {
              Spacer()
                VStack(spacing: 1) {  // reduce spacing between NavigationLinks
                    
                    // Banner View
                    if !currentRouteInstructions.isEmpty {
                        BannerView(
                            currentStepIndex: $currentStepIndex, instructions: currentRouteInstructions,
                            coordinates: routeCoordinates,
                            onPuckLocationUpdate: { coordinate in
                                if let map = mapboxMap {
                                    print("Updating puck to coordinate: \(coordinate)")
                                    updatePuckLocation(to: coordinate, on: map)
                                }
                            })
                    }
                    HStack {
                    HStack {
                        NavigationLink("Select Start Place") {
                            SearchResultView(viewModel: nodeSearchModel) { selectedId in
                                startNode = selectedId
                            }
                        }
                    }
                    .padding(8)
                    .background(.white)
                    .cornerRadius(8)
                    
                    HStack {
                        NavigationLink("Select End Place") {
                            SearchResultView(viewModel: nodeSearchModel) { selectedId in
                                endNode = selectedId
                            }
                        }
                    }
                    .padding(8)
                    .background(.white)
                    .cornerRadius(8)
                    
                    // Segmented Control for Floor Selection
                    Picker("Floor", selection: $selectedFloor) {
                        Text("F1").tag(1)
                        Text("F2").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .onChange(of: selectedFloor) { oldFloor, newFloor in
                        if let map = mapboxMap {
                            //applyFloorVisibility(for: map, floor: newFloor)
                            applyGroupVisibility(for: map, group: "level-\(newFloor)")
                        }
                        nodeSearchModel.loadNodes(forFloor: newFloor)  // Reload nodes for the selected floor
                    }
                }
              }
              .padding(.trailing)
              .padding(.top, 8)  // reduce top padding
            }

            Spacer()  // rest of content push down

            // Bottom buttons
            HStack(spacing: 8) {
              Button("Calculate Route") {
                if let map = mapboxMap {
                  calculateRoute(using: map)
                } else {
                  print("--MapReader did not provide map--")
                }
              }
              .font(.footnote)
              .padding(6)
              .background(.white)
              .cornerRadius(8)

              Button("Clear Route") {
                clearRoute()
              }
              .font(.footnote)
              .padding(6)
              .background(.white)
              .cornerRadius(8)

              NavigationLink(destination: InstructionsView(instructions: currentRouteInstructions)) {
                Text("View Instructions")
                  .font(.footnote)
              }
              .padding(6)
              .background(.white)
              .cornerRadius(8)
            }
            .padding(.bottom, 40)
          }

        }
        .onAppear {
          nodeSearchModel.loadNodes(forFloor: selectedFloor)  // load default nodes
        }

      }
    }
    
    // -- FUNCTIONS --
    
    private func clearRoute() {
        // Clear route-related data
        routeCoordinates.removeAll()
        currentRouteInstructions.removeAll()
        currentStepIndex = 0 // reset step index
        startNode = ""
        endNode = ""
        
        // Remove route layer and source from the map
        if let map = mapboxMap {
            do {
                // Remove route layer
                if try map.layer(withId: "route-layer") != nil {
                    try map.removeLayer(withId: "route-layer")
                }
                // Remove route source
                if try map.source(withId: "route-source") != nil {
                    try map.removeSource(withId: "route-source")
                }
                
                // remove puck layer
                if try map.layer(withId: "puck-layer") != nil {
                    try map.removeLayer(withId: "puck-layer")
                }
                // remove puck source
                if try map.source(withId: "puck-source") != nil {
                    try map.removeSource(withId: "puck-source")
                }
            } catch {
                print("--Error clearing route from map: \(error)--")
            }
        }
    }
    
    
    private func configureUnderlyingMap(_ map: MapboxMap) {
        print("Map is ready for configuration")
    }
    
    
    private func applyGroupVisibility(for map: MapboxMap, group: String) {
        do {
            // Get all layer IDs
            let allLayerIdentifiers = map.allLayerIdentifiers
            
            // Iterate over all layers
            for layerInfo in allLayerIdentifiers {
                let layerId = layerInfo.id
                if layerId.hasPrefix("\(group)-") {
                    // If the layer belongs to the target group, make it visible
                    try map.setLayerProperty(for: layerId, property: "visibility", value: "visible")
                } else if layerId.hasPrefix("level-") {
                    // If the layer belongs to another group, hide it
                    try map.setLayerProperty(for: layerId, property: "visibility", value: "none")
                }
            }
            print("Group \(group) is now visible")
        } catch {
            print("--Error toggling visibility for group \(group): \(error)--")
        }
    }
    
    /* --OLD ADDROUTE--
    private func addRoute(to map: MapboxMap, with coordinates: [CLLocationCoordinate2D]) {
        do {
            let routeFeature = Feature(geometry: .lineString(LineString(coordinates)))
            var routeSource = GeoJSONSource(id: "route-source")
            routeSource.data = .feature(routeFeature)
            
            try map.addSource(routeSource)
            
            var routeLayer = LineLayer(id: "route-layer", source: "route-source")
            routeLayer.lineColor = .constant(StyleColor(.blue))
            routeLayer.lineWidth = .constant(4.0)
            try map.addLayer(routeLayer)
        } catch {
            print("--Error adding route to map: \(error)--")
        }
    } */
    
    
    private func addRoute(to map: MapboxMap, with coordinates: [CLLocationCoordinate2D]) {
            do {
                let routeFeature = Feature(geometry: .lineString(LineString(coordinates)))
                var routeSource = GeoJSONSource(id: "route-source")
                routeSource.data = .feature(routeFeature)
                
                try map.addSource(routeSource)
                
                var routeLayer = LineLayer(id: "route-layer", source: "route-source")
                routeLayer.lineColor = .constant(StyleColor(.blue))
                routeLayer.lineWidth = .constant(4.0)
                
                try map.addLayer(routeLayer)
            } catch {
                print("--Error adding route to map: \(error)--")
            }
        }
    
    // NEW
    private func calculateRoute(using mapboxMap: MapboxMap) {
        let graphManager = GraphManager()
        let pathfinder = Pathfinding()
        let routeInstructionsGenerator = RouteInstructions()
        
        do {
            let nodeFileName = "level-\(selectedFloor)-nodes"
            let edgeFileName = "level-\(selectedFloor)-edges"
            try graphManager.loadData(nodeFileName: nodeFileName, edgeFileName: edgeFileName)
        } catch {
            print("-- Error loading graph data: \(error)")
            return
        }
        
        guard !startNode.isEmpty, !endNode.isEmpty else {
            print("--Missing start/end node")
            currentRouteInstructions = ["Please select both start and end nodes."]
            return
        }
        
        if let result = pathfinder.dijkstra(graph: graphManager.adjacencyList, start: startNode, goal: endNode) {
            let nodePath = result.path.compactMap { graphManager.nodes[$0] }
            routeCoordinates = nodePath.map { $0.coordinate }
            currentRouteInstructions = routeInstructionsGenerator.generateInstructions(for: nodePath)
            
            addRoute(to: mapboxMap, with: routeCoordinates)
            
            if (try? mapboxMap.layer(withId: "puck-layer")) == nil {
                addPuck(to: mapboxMap)
            }
            if let firstCoordinate = routeCoordinates.first {
                updatePuckLocation(to: firstCoordinate, on: mapboxMap)
            }
            
        } else {
            currentRouteInstructions = ["--No path found--"]
        }
    }

    
    // puck functions
    private func addPuck(to map: MapboxMap) {
        do {
            // Add the custom image for the puck
            if let puckImage = UIImage(named: "puck") {
                try map.addImage(puckImage, id: "puck-image")
                print("Puck image added success")
            } else {
                print("Puck image not found")
            }
            
            // Define the GeoJSON source for the puck
            var puckSource = GeoJSONSource(id: "puck-source")
            puckSource.data = .feature(Feature(geometry: .point(Point(CLLocationCoordinate2D(latitude: 0, longitude: 0))))) // Initial placeholder
            
            try map.addSource(puckSource)
            
            // Add a symbol layer to render the puck
            var puckLayer = SymbolLayer(id: "puck-layer", source: "puck-source")
            puckLayer.iconImage = .constant(.name("puck-image"))
            puckLayer.iconSize = .constant(1.0) // Adjust size if needed
            
            try map.addLayer(puckLayer, layerPosition: .above("route-layer"))
            
        } catch {
            print("--Error adding puck to map: \(error)--")
        }
    }
    
    private func updatePuckLocation(to coordinate: CLLocationCoordinate2D, on map: MapboxMap) {
        do {
            let puckFeature = Feature(geometry: .point(Point(coordinate)))
            try map.updateGeoJSONSource(withId: "puck-source", data: .feature(puckFeature))
        } catch {
            print("--Error updating puck location: \(error)--")
        }
    }

}

