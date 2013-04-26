//
//  MKUserLocation+Project.m
//  MapKit
//
//  Created by Rick Fillion on 7/11/10.
//  Copyright 2010 Centrix.ca. All rights reserved.
//

#import "MKUserLocation+Project.h"


@implementation MKUserLocation (Project)

- (void)_setLocation:(CLLocation *)aLocation
{
    [self willChangeValueForKey:@"location"];
    [aLocation retain];
    [location release];
    location = aLocation;
    [self didChangeValueForKey:@"location"];
}

- (void)_setUpdating:(BOOL)value
{
    [self willChangeValueForKey:@"isUpdating"];
    updating = value;
    [self didChangeValueForKey:@"isUpdating"];
}

@end
