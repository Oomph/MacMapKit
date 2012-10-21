//
//  MKCircleTest.m
//  MapKit
//
//  Created by Markus on 20.10.12.
//
//

#import "MKCircleTest.h"
#import <MapKit/MapKit.h>

#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@implementation MKCircleTest


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

#if 0  // TODO: conversion between MapPoints and meters is not correct on MacOSX
- (void)testBoundingMapRect
{
    //Apple Headquarter
    CLLocationCoordinate2D center= CLLocationCoordinate2DMake(37.3326, -122.0303);
  
    
    MKCircle* circle = [MKCircle circleWithCenterCoordinate:center radius:1000.0];
    
    MKMapRect boundingMapRect = circle.boundingMapRect;
    
    assertThatDouble(43216891.34952898,equalToDouble(boundingMapRect.origin.x));
    assertThatDouble(104163483.19862715899944305419921875,equalToDouble(boundingMapRect.origin.y));
    assertThatDouble(16899.8214042689578491263091564178466796875,equalToDouble(boundingMapRect.size.width));
    assertThatDouble(16899.8214042689578491263091564178466796875,equalToDouble(boundingMapRect.size.height));
        
}
#endif

@end
