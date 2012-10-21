//
//  MKGeometry+Private.m
//  MapKit
//
//  Created by Markus on 17.10.12.
//
//

#import "MKGeometry+Private.h"

// Number of pixels for zoom level 20
#define MK_NUMBER_OF_PIXELS_AT_ZOOM_20 268435456.0f

const MKMapSize MKMapSizeWorld = {MK_NUMBER_OF_PIXELS_AT_ZOOM_20,MK_NUMBER_OF_PIXELS_AT_ZOOM_20};

const MKMapRect MKMapRectWorld ={{0,0},{MK_NUMBER_OF_PIXELS_AT_ZOOM_20,MK_NUMBER_OF_PIXELS_AT_ZOOM_20}};



// Functions taken from http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/

#define MERCATOR_OFFSET (MKMapSizeWorld.width/2.0f)
#define MERCATOR_RADIUS (MERCATOR_OFFSET/M_PI)
#define MKPOINTS_PER_METER (6.74355336508965f)
#define WGS_EARTH_RADIUS 6378137.0f


double longitudeToPixelSpaceX(double longitude)
{
//    return MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0f;
    return MERCATOR_OFFSET * (1.0f + (longitude / 180.0f));
}

double latitudeToPixelSpaceY(double latitude)
{
    return MERCATOR_OFFSET - MERCATOR_RADIUS * log((1.0f + sin(latitude * M_PI / 180.0f)) / (1.0f - sin(latitude * M_PI / 180.0f))) / 2.0f;
}

double pixelSpaceXToLongitude(double pixelX)
{
    return (((pixelX/MERCATOR_OFFSET)-1.0f) * 180.0f);
}

double pixelSpaceYToLatitude(double pixelY)
{
    return (M_PI / 2.0f - 2.0f * atan(exp((pixelY - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0f / M_PI;
}




extern  MKMapPoint MKMapPointForCoordinate(CLLocationCoordinate2D coordinate)
{
    return MKMapPointMake(longitudeToPixelSpaceX(coordinate.longitude), latitudeToPixelSpaceY(coordinate.latitude));
    
}

extern  CLLocationCoordinate2D MKCoordinateForMapPoint(MKMapPoint mapPoint)
{
    return CLLocationCoordinate2DMake(pixelSpaceYToLatitude(mapPoint.y), pixelSpaceXToLongitude(mapPoint.x));
}


//FIXME: Conversion functions do not return the same values as iOS MapKit.

double MKMapPointsPerMeterAtLatitude(CLLocationDegrees latitude)
{
	return (cos((latitude * M_PI/ 180.0f)) * MK_NUMBER_OF_PIXELS_AT_ZOOM_20)/(2.0f * M_PI * WGS_EARTH_RADIUS);
}

CLLocationDistance MKMetersPerMapPointAtLatitude(CLLocationDegrees longitude)
{
	return 1.0/MKMapPointsPerMeterAtLatitude(longitude);
}