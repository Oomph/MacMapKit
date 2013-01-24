//
//  MapKitFrameworkTests.m
//  MapKitFrameworkTests
//
//  Created by Jeff Sawatzky on 2013-01-22.
//
//

#import "MKGeometryTests.h"
#import <MapKit/MapKit.h>

@implementation MKGeometryTests

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

- (void)testMKMapPointForCoordinate
{
    // 0, 0 in coordinates is at the equator along the primer meridian which should be ?, ?
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
    double expectedX = 268435456;
    double expectedY = 268435456;
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
    STAssertEquals(expectedX, mapPoint.x, @"x values are different");
    STAssertEquals(expectedY, mapPoint.y, @"y values are different");
}

- (void)testMKCoordinateForMapPoint
{
    // 0, 0 in coordinates is at the top left of the map, which should be around -180, 90 give or take...
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    double expectedLatitude = 85.05112877;
    double expectedLongitude = -180; // I guess there are some rounding errors, and I end up getting 86 instead of 90
    
    CLLocationCoordinate2D coordinate = MKCoordinateForMapPoint(mapPoint);
    STAssertEquals(expectedLatitude, coordinate.latitude, @"latitude values are different");
    STAssertEquals(expectedLongitude, coordinate.longitude, @"longitude values are different");
}

- (void)testMKMetersBetweenMapPoints
{
    CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(0, 0);
    CLLocation * locationA =
    [[CLLocation alloc] initWithLatitude:coordinateA.latitude longitude:coordinateA.longitude];
    
    CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(5, 5);
    CLLocation * locationB =
    [[CLLocation alloc] initWithLatitude:coordinateB.latitude longitude:coordinateB.longitude];
    
    CLLocationDistance expectedDistance = [locationA distanceFromLocation:locationB];
    
    MKMapPoint mapPointA = MKMapPointForCoordinate(coordinateA);
    MKMapPoint mapPointB = MKMapPointForCoordinate(coordinateB);
    double actualDistance = MKMetersBetweenMapPoints(mapPointA, mapPointB);
    
    STAssertEquals(ceil(expectedDistance), ceil(actualDistance), @"distance values are different");
}

- (void)testMKMapRectContainsPoint
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 10, 10);
    MKMapPoint inRectPoint1 = MKMapPointMake(0, 0);
    MKMapPoint inRectPoint2 = MKMapPointMake(5, 5);
    MKMapPoint inRectPoint3 = MKMapPointMake(10, 10);
    
    MKMapPoint notInRectPoint1 = MKMapPointMake(11, 11);
    
    STAssertTrue(MKMapRectContainsPoint(mapRect, inRectPoint1), @"map rect doesn't contain the point like it should");
    STAssertTrue(MKMapRectContainsPoint(mapRect, inRectPoint2), @"map rect doesn't contain the point like it should");
    STAssertTrue(MKMapRectContainsPoint(mapRect, inRectPoint3), @"map rect doesn't contain the point like it should");
    
    STAssertFalse(MKMapRectContainsPoint(mapRect, notInRectPoint1), @"map rect doesn't contain the point like it should");
}

@end
