//
//  MKPolyLineTest.m
//  MapKit
//
//  Created by Markus on 21.10.12.
//
//

#import "MKPolyLineTest.h"

#import <MapKit/MapKit.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>



@implementation MKPolyLineTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testPolygonWithCoordinates
{
    CLLocationCoordinate2D coordinates[] = {
        {37.818844,-122.366278},
        {37.819267,-122.365248},
        {37.819861,-122.365640},
        {37.819429,-122.366669},
        {37.818844,-122.366278}
    };
    
    
    MKPolyline* polyline = [MKPolyline polylineWithCoordinates:coordinates count:5];
    
    MKMapRect boundingMapRect = polyline.boundingMapRect;
    
    assertThatDouble(42974526.354955375194549560546875,equalToDouble(boundingMapRect.origin.x));
    assertThatDouble(103713496.57613144814968109130859375,equalToDouble(boundingMapRect.origin.y));
    assertThatDouble(1059.574397161603,equalToDouble(boundingMapRect.size.width));
    assertThatDouble(959.9748493880033,equalToDouble(boundingMapRect.size.height));
    
}
@end

