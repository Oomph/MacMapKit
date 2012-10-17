//
//  MKPolygonTest.m
//  MapKit
//
//  Created by Markus on 17.10.12.
//
//

#import "MKPolygonTest.h"
#import "MKPolygon.h"

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
    MKPolygon* polygon = [MKPolygon polygonWithCoordinates:<#(CLLocationCoordinate2D *)#> count:<#(NSUInteger)#>]
}
@end
