//
//  MKPolyline.m
//  MapKit
//
//  Created by Rick Fillion on 7/15/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKPolyline.h"

@interface MKPolyline (Private)

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;

@end


@implementation MKPolyline

+ (MKPolyline *)polylineWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    return [[[MKPolyline alloc] initWithCoordinates:coords count:count] autorelease];
}

+ (MKPolyline *)polylineWithPoints:(MKMapPoint *)points count:(NSUInteger)count
{
    return [[[MKPolyline alloc] initWithPoints:points count:count] autorelease];
}

- (CLLocationCoordinate2D) coordinate
{
    return [super coordinate];
}

- (void)dealloc
{
    free(points);
    [super dealloc];
}

#pragma mark Private

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    if (self = [super init])
    {
        points = malloc(sizeof(MKMapPoint) * count);
        for (int i = 0; i < count; i++)
        {
            points[i] = MKMapPointForCoordinate(coords[i]);
        }
        pointCount = count;
    }
    return self;
}

- (id)initWithPoints:(MKMapPoint *)coords count:(NSUInteger)count
{
    if (self = [super init])
    {
        points = malloc(sizeof(MKMapPoint) * count);
        for (int i = 0; i < count; i++)
        {
            points[i] = coords[i];
        }
        pointCount = count;
    }
    return self;
}

@end
