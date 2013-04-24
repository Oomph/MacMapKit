/*
 *  MKGeometry.h
 *  MapKit
 *
 *  Created by Jeff Sawatzky on 2013-01-22.
 *
 */

#import "MKGeometry.h"

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS (MERCATOR_OFFSET/M_PI)
#define WGS84_RADIUS 6378137
#define POINTS_PER_METER (MERCATOR_RADIUS / WGS84_RADIUS)

// the min latitude based on the mercator projection
double const MIN_LATITUDE = -85.05112877;

// the max latitude based on the mercator projection
double const MAX_LATITUDE = 85.05112877;

// the min longitude based on the mercator projection
double const MIN_LONGITUDE = -180;

// the max longitude based on the mercator projection
double const MAX_LONGITUDE = 180;


#pragma mark - Map Projection Math
// From http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/

double MKGeometryLongitudeToPixelSpaceX(CLLocationDegrees lng)
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * lng * M_PI / 180.0);
}

double MKGeometryLatitudeToPixelSpaceY(CLLocationDegrees lat)
{
    return (MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(lat * M_PI / 180.0)) / (1 - sin(lat * M_PI / 180.0))) / 2.0);
}

double MKGeometryPixelSpaceXToLongitude(double x)
{
    return ((x - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

double MKGeometryPixelSpaceYToLatitude(double y)
{
    return (M_PI / 2.0 - 2.0 * atan(exp((y - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark - Implementation

MKMapPoint MKMapPointForCoordinate(CLLocationCoordinate2D coordinate)
{
    CLLocationDegrees latitude = MIN(MAX(coordinate.latitude, MIN_LATITUDE), MAX_LATITUDE);
    CLLocationDegrees longitude = MIN(MAX(coordinate.longitude, MIN_LONGITUDE), MAX_LONGITUDE);
    
    double x = MAX(MKGeometryLongitudeToPixelSpaceX(longitude), 0);
    double y = MAX(MKGeometryLatitudeToPixelSpaceY(latitude), 0);
    
    return MKMapPointMake(x, y);
}

CLLocationCoordinate2D MKCoordinateForMapPoint(MKMapPoint mapPoint)
{
    double x = MAX(mapPoint.x, 0);
    double y = MAX(mapPoint.y, 0);
    
    CLLocationDegrees latitude = MIN(MAX(MKGeometryPixelSpaceYToLatitude(y), MIN_LATITUDE), MAX_LATITUDE);
    CLLocationDegrees longitude = MIN(MAX(MKGeometryPixelSpaceXToLongitude(x), MIN_LONGITUDE), MAX_LONGITUDE);
    
    return CLLocationCoordinate2DMake(latitude, longitude);
}

CLLocationDistance MKMetersPerMapPointAtLatitude(CLLocationDegrees latitude) {
    return 1 / MKMapPointsPerMeterAtLatitude(latitude);
}

double MKMapPointsPerMeterAtLatitude(CLLocationDegrees latitude) {
    return POINTS_PER_METER / cos(latitude * M_PI / 180.0);
}

CLLocationDistance MKMetersBetweenMapPoints(MKMapPoint a, MKMapPoint b)
{
    CLLocationCoordinate2D coordinateA = MKCoordinateForMapPoint(a);
    CLLocation * locationA = [[CLLocation alloc] initWithLatitude:coordinateA.latitude longitude:coordinateA.longitude];
    
    CLLocationCoordinate2D coordinateB = MKCoordinateForMapPoint(b);
    CLLocation * locationB = [[CLLocation alloc] initWithLatitude:coordinateB.latitude longitude:coordinateB.longitude];
    
    return [locationA distanceFromLocation:locationB];
}

MKMapRect MKMapRectUnion(MKMapRect rect1, MKMapRect rect2)
{
    if (MKMapRectIsNull(rect1)) {
        return rect2;
    }
    
    if (MKMapRectIsNull(rect2)) {
        return rect1;
    }
    
    double minX = MIN(rect1.origin.x, rect2.origin.x);
    double maxX = MAX(rect1.origin.x, rect2.origin.x);
    double minY = MIN(rect1.origin.y, rect2.origin.y);
    double maxY = MAX(rect1.origin.y, rect2.origin.y);
    
    return MKMapRectMake(minX, minY, maxX - minX, maxY-minY);
}

MKMapRect MKMapRectIntersection(MKMapRect rect1, MKMapRect rect2)
{
    NSRect aRect = NSMakeRect(rect1.origin.x, rect1.origin.y, rect1.size.width, rect1.size.height);
    NSRect bRect = NSMakeRect(rect2.origin.x, rect2.origin.y, rect2.size.width, rect2.size.height);
    NSRect intersection = NSIntersectionRect(aRect, bRect);
    return MKMapRectMake(intersection.origin.x, intersection.origin.y, intersection.size.width, intersection.size.height);
}

MKMapRect MKMapRectInset(MKMapRect rect, double dx, double dy)
{
    NSRect aRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    aRect = NSInsetRect(aRect, dx, dy);
    return MKMapRectMake(aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
}

MKMapRect MKMapRectOffset(MKMapRect rect, double dx, double dy)
{
    NSRect aRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    aRect = NSOffsetRect(aRect, dx, dy);
    return MKMapRectMake(aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
}

BOOL MKMapRectContainsPoint(MKMapRect rect, MKMapPoint point)
{
    if (rect.origin.x <= point.x && (rect.origin.x + rect.size.width) >= point.x &&
        rect.origin.y <= point.y && (rect.origin.y + rect.size.height) >= point.y) {
        return YES;
    } else {
        return NO;
    }
}

MKCoordinateRegion MKCoordinateRegionForMapRect(MKMapRect rect)
{
    // figure out the center point
    MKMapPoint centerPoint =
    MKMapPointMake(rect.origin.x + (rect.size.width / 2), rect.origin.y + (rect.size.height / 2));
    CLLocationCoordinate2D centerCoord = MKCoordinateForMapPoint(centerPoint);
    
    // figure out the position of the top-left pixel
    MKMapPoint topLeftPoint = MKMapPointMake(rect.origin.x, rect.origin.y);
    CLLocationCoordinate2D topLeftCoord = MKCoordinateForMapPoint(topLeftPoint);
    
    // figure out the position of the bottom-right pixel
    MKMapPoint bottomRightPoint = MKMapPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    CLLocationCoordinate2D bottomRightCoord = MKCoordinateForMapPoint(bottomRightPoint);
    
    // find delta between top and bottom latitudes
    CLLocationDegrees latitudeDelta = topLeftCoord.latitude - bottomRightCoord.latitude;
    
    // find delta between left and right longitudes
    CLLocationDegrees longitudeDelta = bottomRightCoord.longitude - topLeftCoord.longitude;
    
    return MKCoordinateRegionMake(centerCoord, MKCoordinateSpanMake(latitudeDelta, longitudeDelta));
}