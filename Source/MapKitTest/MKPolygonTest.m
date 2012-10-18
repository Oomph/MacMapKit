//
//  MKPolygonTest.m
//  MapKit
//
//  Created by Markus on 17.10.12.
//
//

#import "MKPolygonTest.h"
#import <MapKit/MapKit.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>



@implementation MKPolygonTest

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
        {-122.366278,37.818844},
        {-122.365248,37.819267},
        {-122.365640,37.819861},
        {-122.366669,37.819429},
        {-122.366278,37.818844}
    };
    
    MKPolygon* polygon = [MKPolygon polygonWithCoordinates:coordinates count:sizeof(coordinates)];
    
    MKMapRect boundingMapRect = polygon.boundingMapRect;
    
    assertThatDouble(1.5,equalToDouble(boundingMapRect.origin.x));
    
    
}
@end
