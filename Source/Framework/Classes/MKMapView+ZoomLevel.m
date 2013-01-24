//
//  MKMapView+ZoomLevel.m
//  MapKit
//
//  From http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/
//  Note that some of the functions were put into MKGeometry and this was updated to make use of that
//

#import "MKMapView+ZoomLevel.h"

@implementation MKMapView (ZoomLevel)

#pragma mark - Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    zoomLevel = MAX(zoomLevel, 0);
    zoomLevel = MIN(zoomLevel, 20);
    
    // convert center coordiate to pixel space
    MKMapPoint center = MKMapPointForCoordinate(centerCoordinate);
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    CGFloat scaledMapWidth = mapSizeInPixels.width * zoomScale;
    CGFloat scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    MKMapPoint topLeftPoint = MKMapPointMake(center.x - (scaledMapWidth / 2), center.y - (scaledMapHeight / 2));
    CLLocationCoordinate2D topLeftCoord = MKCoordinateForMapPoint(topLeftPoint);
    
    // figure out the position of the bottom-right pixel
    MKMapPoint bottomLeftRight = MKMapPointMake(topLeftPoint.x + scaledMapWidth, topLeftPoint.y + scaledMapHeight);
    CLLocationCoordinate2D bottomRightCoord = MKCoordinateForMapPoint(bottomLeftRight);
    
    // find delta between left and right longitudes
    CLLocationDegrees longitudeDelta = bottomRightCoord.longitude - topLeftCoord.longitude;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees latitudeDelta = topLeftCoord.latitude - bottomRightCoord.latitude;
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark - Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

@end
