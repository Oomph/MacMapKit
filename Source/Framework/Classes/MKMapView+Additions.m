//
//  MKMapView+Additions.m
//  MapKit
//
//  Created by Rick Fillion on 7/24/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKMapView+Additions.h"
#import <WebKit/WebKit.h>


@implementation MKMapView (Additions)

- (void)addJavascriptTag:(NSString *)urlString
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSURL *url = [NSURL URLWithString:urlString];
    NSArray *args = [NSArray arrayWithObject:[url filePathURL]];
    [webScriptObject callWebScriptMethod:@"addJavascriptTag" withArguments:args];
}

- (void)addStylesheetTag:(NSString *)urlString
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = [NSArray arrayWithObject:urlString];
    [webScriptObject callWebScriptMethod:@"addStylesheetTag" withArguments:args];
}

- (void)showAddress:(NSString *)address
{
    WebScriptObject *webScriptObject = [webView windowScriptObject];
    NSArray *args = [NSArray arrayWithObject:address];
    [webScriptObject callWebScriptMethod:@"showAddress" withArguments:args]; 
}

#pragma mark NSControl

- (void)takeStringValueFrom:(id)sender
{
    if (![sender respondsToSelector:@selector(stringValue)])
    {
        NSLog(@"sender must respond to -stringValue");
        return;
    }
    NSString *stringValue = [sender stringValue];
    [self showAddress:stringValue];
}

#pragma mark ZoomLevel

- (MKCoordinateSpan)_coordinateSpanWithMapView:(MKMapView *)mapView
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
    NSSize mapSizeInPixels = mapView.bounds.size;
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

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self _coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}

#pragma mark Close

- (void)close
{
	[self setDelegate:nil];
	[webView close];
	[[webView windowScriptObject] setValue:nil forKey:@"WindowScriptObject"];
	[[webView windowScriptObject] setValue:nil forKey:@"MKMapView"];
}

@end
