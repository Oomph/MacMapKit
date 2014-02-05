//
//  MKMultiPoint.m
//  MapKit
//
//  Created by Rick Fillion on 7/15/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKMultiPoint.h"


@implementation MKMultiPoint

@synthesize points;
@synthesize pointCount;


- (void)getCoordinates:(CLLocationCoordinate2D *)coords range:(NSRange)range
{
    for (int i = range.location; i < MAX(range.location+range.length, pointCount); i++)
    {
        coords[i] = MKCoordinateForMapPoint(points[i]);
    }
}

@end
