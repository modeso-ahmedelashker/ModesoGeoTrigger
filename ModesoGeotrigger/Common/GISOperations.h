//
//  GISOperations.h
//  ModesoGeotrigger
//
//  Created by Modeso on 2/18/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface GISOperations : NSObject

+ (AGSMutableEnvelope *)envelopeFromGeometry:(AGSGeometry *)incomingGeometry;

@end
