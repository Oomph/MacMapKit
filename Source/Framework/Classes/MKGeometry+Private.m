//
//  MKGeometry+Private.m
//  MapKit
//
//  Created by Markus on 17.10.12.
//
//

#import "MKGeometry+Private.h"

// Number of pixels for zoom level 10
#define MK_NUMBER_OF_PIXELS_AT_ZOOM_10 268435456.0f

const MKMapSize MKMapSizeWorld = {MK_NUMBER_OF_PIXELS_AT_ZOOM_10,MK_NUMBER_OF_PIXELS_AT_ZOOM_10};

const MKMapRect MKMapRectWorld ={{0,0},{MK_NUMBER_OF_PIXELS_AT_ZOOM_10,MK_NUMBER_OF_PIXELS_AT_ZOOM_10}};



// Functions taken from http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/

#define MERCATOR_OFFSET MKMapSizeWorld.width/2.0f
#define MERCATOR_RADIUS MERCATOR_OFFSET/M_PI

double longitudeToPixelSpaceX(double longitude)
{
//    return MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0f;
    return MERCATOR_OFFSET * (1+ (longitude / 180.0f));
}

double latitudeToPixelSpaceY(double latitude)
{
    return MERCATOR_OFFSET - MERCATOR_RADIUS * log((1.0f + sin(latitude * M_PI / 180.0f)) / (1.0f - sin(latitude * M_PI / 180.0f))) / 2.0f;
}

double pixelSpaceXToLongitude(double pixelX)
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0f / M_PI;
}

double pixelSpaceYToLatitude(double pixelY)
{
    return (M_PI / 2.0f - 2.0f * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0f / M_PI;
}




extern  MKMapPoint MKMapPointForCoordinate(CLLocationCoordinate2D coordinate)
{
    return MKMapPointMake(longitudeToPixelSpaceX(coordinate.longitude), latitudeToPixelSpaceY(coordinate.latitude));
    
}

extern  CLLocationCoordinate2D MKCoordinateForMapPoint(MKMapPoint mapPoint)
{
    return CLLocationCoordinate2DMake(pixelSpaceYToLatitude(mapPoint.y), pixelSpaceXToLongitude(mapPoint.x));
}