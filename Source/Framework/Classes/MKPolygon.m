//
//  MKPolygon.m
//  MapKit
//
//  Created by Rick Fillion on 7/15/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKPolygon.h"

@interface MKPolygon (Private)

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count;
- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count interiorPolygons:(NSArray *)interiorPolygons;

@end

@implementation MKPolygon



@synthesize boundingMapRect;
@synthesize interiorPolygons;

+ (MKPolygon *)polygonWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    return [[[self alloc] initWithCoordinates:coords count:count] autorelease];
}

+ (MKPolygon *)polygonWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count interiorPolygons:(NSArray *)interiorPolygons;
{
    return [[[self alloc] initWithCoordinates:coords count:count interiorPolygons:interiorPolygons] autorelease];
}

- (CLLocationCoordinate2D) coordinate
{
    return [super coordinate];
}

- (void)dealloc
{
    free(coordinates);
    [interiorPolygons release];
    [super dealloc];
}

#pragma mark Private

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    if (self = [super init])
    {
        coordinates = malloc(sizeof(CLLocationCoordinate2D) * count);
        
        MKMapPoint minXY = MKMapPointForCoordinate(*coords);
        MKMapPoint maxXY = MKMapPointForCoordinate(*coords);
        
        for (int i = 0; i < count; i++)
        {
            coordinates[i] = coords[i];
            
            MKMapPoint mapPoint = MKMapPointForCoordinate(coords[i]);
            
            minXY.x= MIN(minXY.x,mapPoint.x);
            minXY.y= MIN(minXY.y,mapPoint.y);
            maxXY.x= MAX(maxXY.x,mapPoint.x);
            maxXY.y= MAX(maxXY.y,mapPoint.y);

            
         }
        
        boundingMapRect = MKMapRectMake(minXY.x, minXY.y, (double)(maxXY.x-minXY.x), (double) maxXY.y-minXY.y);
        
        coordinateCount = count;
    }
    return self;
}

- (id)initWithCoordinates:(CLLocationCoordinate2D *)coords count:(NSUInteger)count interiorPolygons:(NSArray *)theInteriorPolygons
{
    if (self = [self initWithCoordinates:coords count:count])
    {
        interiorPolygons = [theInteriorPolygons retain];
    }
    return self;
}






@end
