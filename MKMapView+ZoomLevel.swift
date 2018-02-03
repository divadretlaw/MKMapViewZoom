//
//  MKMapView+ZoomLevel.swift
//  MKMapView+ZoomLevel
//
//  Created by David Walter on 01.03.15.
//  Copyright (c) 2015 David Walter. All rights reserved.
//

import MapKit

extension MKMapView {
    
    public func coordinateSpanWith(mapView: MKMapView, centerCoordinate: CLLocationCoordinate2D, zoomLevel: Double) -> MKCoordinateSpan {
        
        let centerPixel = centerCoordinate.pixel
        
        let zoomScale = pow(2, 20 - zoomLevel)
        let width = Double(mapView.bounds.size.width) * zoomScale
        let height = Double(mapView.bounds.size.width) * zoomScale
        
        let topLeftPixel = Pixel(x: centerPixel.x - width / 2, y: centerPixel.y - height / 2)
        
        let longitudeDelta = topLeftPixel.longitudeDelta(offset: width)
        let latitudeDelta = topLeftPixel.latitudeDelta(offset: height)
        
        return MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    }
    
    public func setCenter(coordinate: CLLocationCoordinate2D, zoomLevel: Double, animated:(Bool)) {
        let span = self.coordinateSpanWith(mapView: self, centerCoordinate: coordinate, zoomLevel: min(zoomLevel, 28.0))
        let region = MKCoordinateRegionMake(coordinate, span)
        
        self.setRegion(region, animated: animated)
    }
    
    public var zoomLevel: Double {
        let left = (centerCoordinate.longitude - region.span.longitudeDelta / 2)
        let right = (centerCoordinate.longitude + region.span.longitudeDelta / 2)
        
        let leftPixel = round(268435456 + 85445659.44705395 * left * .pi / 180)
        let rightPixel = round(268435456 + 85445659.44705395 * right * .pi / 180)
        
        let pixelDelta = abs(rightPixel - leftPixel)
        let zoomScale = Double(bounds.size.width) / pixelDelta
        let zoomExponent = log2(zoomScale)
        
        return 20.0 + zoomExponent
    }
    
}

extension CLLocationCoordinate2D {
    fileprivate var pixel: Pixel {
        let x = round(268435456 + 85445659.44705395 * self.longitude * .pi / 180)
        let y = round(268435456 + 85445659.44705395 * log((1 + sin(self.latitude * .pi / 180.0)) / (1 - sin(self.latitude * .pi / 180.0))) / 2.0)
        
        return Pixel(x: x, y: y)
    }
}

fileprivate struct Pixel {
    var x: Double
    var y: Double
    
    func longitude(offset: Double = 0) -> Double {
        return ((round(self.x + offset) - 268435456) / 85445659.44705395) * 180.0 / .pi;
    }
    
    func longitudeDelta(offset: Double) -> Double {
        let minLng = self.longitude()
        let maxLng = self.longitude(offset: offset)
        return maxLng - minLng
    }
    
    func latitude(offset: Double = 0) -> Double {
        return (.pi / 2.0 - 2.0 * atan(exp((round(self.y + offset) - 268435456) / 85445659.44705395))) * 180.0 / .pi;
    }
    
    func latitudeDelta(offset: Double) -> Double {
        let minLat = self.latitude()
        let maxLat = self.latitude(offset: offset)
        return -1 * (maxLat - minLat)
    }
}
