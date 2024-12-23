//
//  MapViewController.swift
//  MapMe
//
//  Created by Crypto on 12/17/24.
//

import UIKit
import MapboxMaps
/*
class MapViewController: UIViewController {
    internal var mapView: MapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myMapInitOptions = MapInitOptions(
            styleURI: StyleURI(rawValue: "mapbox://styles/fr3shtricks/cm3w53d4700c601rdgzjp53h9"))
        
        mapView = MapView(frame: view.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // The building layout should appear automatically if part of the custom style.
        // If building data is a separate GeoJSON, you might add it as a layer/source programmatically.
    }
    
    // functions to test
    func testAlgorithm() {
            let graphManager = GraphManager()
            let pathfinder = Pathfinding()
            
            do {
                try graphManager.loadData(nodeFileName: "level-1-nodes", edgeFileName: "level-1-edges")
            } catch {
                print("Error loading data: \(error)")
                return
            }
            
            if let result = pathfinder.dijkstra(graph: graphManager.adjacencyList, start: "110", goal: "172") {
                let nodePath = result.path.compactMap { graphManager.nodes[$0] }
                let coordinates = nodePath.map { $0.coordinate }
                self.drawRouteOnMap(coordinates)
            } else {
                print("No path found.")
            }
        }

    func drawRouteOnMap(_ coordinates: [CLLocationCoordinate2D]) {
        // access the MapboxMap instance
        guard let style = mapView?.mapboxMap else {
            print("Failed to access the map style")
            return
        }
        
        // Create a LineString feature
        let routeFeature = Feature(geometry: .lineString(LineString(coordinates)))

        // provide an 'id' for the geoJSON source
        var routeSource = GeoJSONSource(id: "route-source")
        routeSource.data = .feature(routeFeature)
        /*
        // Add source
        try? style.addSource(routeSource, id: "route-source")
        
        // Add line layer
        var routeLayer = LineLayer(id: "route-layer")
        routeLayer.source = "route-source"
        routeLayer.lineColor = .constant(StyleColor(.blue))
        routeLayer.lineWidth = .constant(3.0)
        try? style.addLayer(routeLayer)
         */
        
        do {
            // add the source to the map
            try style.addSource(routeSource)
            
            // Initialize the line layer with an 'id' and 'source'
            var routeLayer = LineLayer(id: "route-layer", source: "route-source")
            routeLayer.lineColor = .constant(StyleColor(.blue))
            routeLayer.lineWidth = .constant(3.0)
            
            // add layer to the map
            try style.addLayer(routeLayer)
        } catch {
            print("Failed to add route on map: \(error)")
        }
    }
}
*/
