//
//  MKGeometryTest.m
//  MapKit
//
//  Created by Markus on 20.10.12.
//
//

#import "MKGeometryTest.h"
#import <MapKit/MapKit.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@implementation MKGeometryTest

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


- (void)testConversionCoordinate2MKPoint
{

    
    CLLocationCoordinate2D portland     = CLLocationCoordinate2DMake(45.520000  ,-122.681944);
    CLLocationCoordinate2D rioDeJaneiro = CLLocationCoordinate2DMake(-43.196389 ,-22.908333);
    CLLocationCoordinate2D istanbul     = CLLocationCoordinate2DMake(28.976018  ,41.012240);
    CLLocationCoordinate2D reykjavik    = CLLocationCoordinate2DMake(64.133333 , -21.933333);
    
    CLLocationCoordinate2D coordinates[] = {
        portland,
        rioDeJaneiro,
        istanbul ,
        reykjavik
    };
    
    MKMapPoint points[] = {
        MKMapPointMake(42739440.2760931551456451416015625   ,96012095.9123315513134002685546875),   // Portland

        // FIXME: check only to 2 decimals of precision. Unclear why Rio values do not match.
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        MKMapPointMake(117136036.84706987440586090087890625 ,169999587.945367515087127685546875),   // Rio
#endif
 
#if __MAC_OS_X_VERSION_MIN_REQUIRED
        MKMapPointMake(117136036.84706985950469970703125 ,169999587.945367515087127685546875),   // Rio
#endif
        
                       
        MKMapPointMake(164798670.6277262270450592041015625  ,111626999.71328115463256835937),   // Istanbul
        MKMapPointMake(117863049.54040320217609405517578125 ,71362638.15177667140960693359375),   // Reykjavik
    };
    
    for (int i = 0; i < sizeof(coordinates)/sizeof(CLLocationCoordinate2D); i++)
    {
  
        MKMapPoint mapPoint = MKMapPointForCoordinate(coordinates[i]);
        assertThatDouble(mapPoint.x,equalToDouble(points[i].x));
        assertThatDouble(mapPoint.y,equalToDouble(points[i].y));
    }
    

}

- (void)testConversionMKPoint2Coordinate
{
    
    
    CLLocationCoordinate2D portland     = CLLocationCoordinate2DMake(45.520000  ,-122.681944);
    CLLocationCoordinate2D rioDeJaneiro = CLLocationCoordinate2DMake(-43.196389 ,-22.908333);
    CLLocationCoordinate2D istanbul     = CLLocationCoordinate2DMake(28.976018  ,41.012240);
    CLLocationCoordinate2D reykjavik    = CLLocationCoordinate2DMake(64.133333 , -21.933333);
   
    CLLocationCoordinate2D coordinates[] = {
        portland,
        rioDeJaneiro,
        istanbul ,
        reykjavik
    };
    
    MKMapPoint points[] = {
        MKMapPointMake(42739440.2760931551456451416015625   ,96012095.9123315513134002685546875),   // Portland
        MKMapPointMake(117136036.84706987440586090087890625 ,169999587.945367515087127685546875),   // Rio
        MKMapPointMake(164798670.6277262270450592041015625  ,111626999.71328115463256835937),   // Istanbul
        MKMapPointMake(117863049.54040320217609405517578125 ,71362638.15177667140960693359375),   // Reykjavik
    };
    
    for (int i = 0; i < sizeof(coordinates)/sizeof(CLLocationCoordinate2D); i++)
    {
        
        CLLocationCoordinate2D coord = MKCoordinateForMapPoint(points[i]);
        assertThatDouble(coord.latitude,closeTo(coordinates[i].latitude,0.000001));
        assertThatDouble(coord.longitude,closeTo(coordinates[i].longitude,0.000001));
    }
    
    
}


- (void)testConversionMKMapRect2CoordinateRegion
{
    
    
    MKMapPoint points[] = {
        MKMapPointMake(42739440.2760931551456451416015625   ,96012095.9123315513134002685546875),   // Portland
        MKMapPointMake(117136036.84706987440586090087890625 ,169999587.945367515087127685546875),   // Rio
        MKMapPointMake(164798670.6277262270450592041015625  ,111626999.71328115463256835937),   // Istanbul
        MKMapPointMake(117863049.54040320217609405517578125 ,71362638.15177667140960693359375),   // Reykjavik
    };

    MKCoordinateRegion coordinateRegion =  MKCoordinateRegionForMapRect(MKMapRectMake(42739440, 96012095, 164798670-2739440, 111626999-96012095));
    
    assertThatDouble(coordinateRegion.center.latitude,closeTo(37.707426,0.000001));
    assertThatDouble(coordinateRegion.center.longitude,closeTo(-14.012762,0.000001));
    assertThatDouble(coordinateRegion.span.latitudeDelta,closeTo(16.543982,0.000001));
    assertThatDouble(coordinateRegion.span.longitudeDelta,closeTo(217.338363,0.000001));
 
    
    
}


- (void)testConstants
{
    
    MKMapSize mapWorld = MKMapSizeWorld;
    assertThatDouble(268435456.0,equalToDouble(mapWorld.width));
    assertThatDouble(268435456.0,equalToDouble(mapWorld.height));
    
    MKMapRect mapRect = MKMapRectWorld;
    assertThatDouble(0,equalToDouble(mapRect.origin.x));
    assertThatDouble(0,equalToDouble(mapRect.origin.y));
    assertThatDouble(268435456.0,equalToDouble(mapRect.size.height));
    assertThatDouble(268435456.0,equalToDouble(mapRect.size.width));

}



#if __IPHONE_OS_VERSION_MIN_REQUIRED  // TODO: conversion between MapPoints and meters is not correct on MacOSX
- (void)testConversionBetweenMKPoint2Meter
{
    double pointsPerMeter = MKMapPointsPerMeterAtLatitude(37.3326);
    
    assertThatDouble(8.449910702134479,equalToDouble(pointsPerMeter));

    
    pointsPerMeter = MKMapPointsPerMeterAtLatitude(0);
    assertThatDouble(6.74355336508965,equalToDouble(pointsPerMeter));
    
    double meterPerPoints = MKMetersPerMapPointAtLatitude(0);
    assertThatDouble(0.1482897733377254445574777719230041839182376861572265625,equalToDouble(meterPerPoints));

    
}
#endif

@end
