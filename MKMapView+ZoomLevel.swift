//
//  MKMapView+ZoomLevel.swift
//  Test
//
//  Created by David Walter on 01.03.15.
//  Copyright (c) 2015 David Walter. All rights reserved.
//

import MapKit

extension MKMapView {

    func coordinateSpanWithMapView(mapView: MKMapView, centerCoordinate:CLLocationCoordinate2D, zoomLevel:(Double)) -> MKCoordinateSpan {
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)

        let zoomScale = pow(2, 20 - zoomLevel)
        let scaledMapWidth = Double(mapView.bounds.size.width) * zoomScale
        let scaledMapHeight = Double(mapView.bounds.size.width) * zoomScale

        let topLeftPixelX = centerPixelX - scaledMapWidth / 2
        let topLeftPixelY = centerPixelY - scaledMapHeight / 2

        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng

        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat  = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1 * (maxLat - minLat)

        return MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
    }

    func setCenterCoordinate(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Double, animated:(Bool)) {
        let span = self.coordinateSpanWithMapView(mapView: self, centerCoordinate: centerCoordinate, zoomLevel: min(zoomLevel, 28.0))
        let region = MKCoordinateRegionMake(centerCoordinate, span)

        self.setRegion(region, animated: animated)
    }

    func getZoomLevel() -> Double {
        let left = (centerCoordinate.longitude - region.span.longitudeDelta / 2)
        let right = (centerCoordinate.longitude + region.span.longitudeDelta / 2)

        let leftPixel = longitudeToPixelSpaceX(longitude: left)
        let rightPixel = longitudeToPixelSpaceX(longitude: right)

        let pixelDelta = abs(rightPixel - leftPixel)
        let zoomScale = Double(bounds.size.width) / pixelDelta
        let zoomExponent = log2(zoomScale)

        return 20.0 + zoomExponent
    }

    func longitudeToPixelSpaceX(longitude: Double) -> Double {
        return round(268435456 + 85445659.44705395 * longitude * M_PI / 180)
    }

    func latitudeToPixelSpaceY(latitude: Double) -> Double {
        return round(268435456 + 85445659.44705395 * log((1 + sin(latitude * M_PI / 180.0)) / (1 - sin(latitude * M_PI / 180.0))) / 2.0)
    }

    func pixelSpaceXToLongitude(pixelX: Double) -> Double {
        return ((round(pixelX) - 268435456) / 85445659.44705395) * 180.0 / M_PI;
    }

    func pixelSpaceYToLatitude(pixelY: Double) -> Double {
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - 268435456) / 85445659.44705395))) * 180.0 / M_PI;
    }
}
