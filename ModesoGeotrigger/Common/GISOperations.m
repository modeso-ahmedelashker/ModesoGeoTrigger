//
//  GISOperations.m
//  ModesoGeotrigger
//
//  Created by Modeso on 2/18/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "GISOperations.h"

@implementation GISOperations

+ (AGSMutableEnvelope *)envelopeFromGeometry:(AGSGeometry *)incomingGeometry {
    
    AGSMutableEnvelope *newEnv = [AGSMutableEnvelope envelopeWithXmin:incomingGeometry.envelope.xmin ymin:incomingGeometry.envelope.ymin xmax:incomingGeometry.envelope.xmax ymax:incomingGeometry.envelope.ymax spatialReference:incomingGeometry.spatialReference];
    
    [newEnv expandByFactor:1.25];
    
    return newEnv;
}

@end
