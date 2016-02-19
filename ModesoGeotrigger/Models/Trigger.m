//
//  TriggerModel.m
//  ModesoGeotrigger
//
//  Created by Modeso on 2/3/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "Trigger.h"

@implementation Trigger

- (id)initWithDictionary:(NSDictionary *)triggerDic GeoEngine:(AGSGeometryEngine *)geoEngine SpatialReference:(AGSSpatialReference *)spatialReference
{
    self = [super init];
    
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        
        //---------------------------[1] Init instance objects----------------------------
        if (self.tags == nil)
        {
            self.tags = [[NSMutableArray alloc] init];
        }
        
        if (self.notifData == nil)
        {
            self.notifData = [[NSMutableDictionary alloc] init];
        }
        
        if (self.graphic == nil)
        {
            self.graphic = [[AGSGraphic alloc] init];
        }
        
        if (self.allPromotionsKeys == nil)
        {
            self.allPromotionsKeys = [NSMutableArray array];
        }
        
        if (self.allPromotionsValues == nil)
        {
            self.allPromotionsValues = [NSMutableArray array];
        }
        
        //---------------------------[2] Set values from Dic, GE and SR--------------------
        for (NSString *tag in triggerDic[@"tags"])
        {
            [self.tags addObject:tag];
        }
        
        self.notifData = [NSMutableDictionary dictionaryWithDictionary:triggerDic[@"action"][@"notification"][@"data"]];
        
        NSDictionary *esriJson = ((triggerDic[@"condition"])[@"geo"])[@"esrijson"];
        
        AGSGeometry *geometry = AGSGeometryWithJSONAndSR(esriJson, spatialReference);
        
        AGSGeometry *newGeo = [geoEngine projectGeometry:geometry toSpatialReference:spatialReference];
        
        // Give data into geometries
        self.graphic = [[AGSGraphic alloc] init];
        [self.graphic setGeometry:newGeo];
        
        if (![(NSString*)triggerDic[@"triggerId"] isEqualToString:nil])
        {
            [self.graphic setAttribute:triggerDic[@"triggerId"] forKey:@"triggerID"];
        }
        if (![(NSString*)triggerDic[@"action"][@"notification"][@"text"] isEqualToString:nil])
        {
            [self.graphic setAttribute:triggerDic[@"action"][@"notification"][@"text"] forKey:@"message"];
        }
        if (![[NSString stringWithFormat:@"%@", triggerDic[@"action"][@"notification"][@"data"]] isEqualToString:nil]) {
            [self.graphic setAttribute:[NSString stringWithFormat:@"%@", triggerDic[@"action"][@"notification"][@"data"]] forKey:@"data"];
        }
        if (![(NSString*)triggerDic[@"action"][@"notification"][@"data"][@"Shop"][@"Name"] isEqualToString:nil])
        {
            [self.graphic setAttribute:triggerDic[@"action"][@"notification"][@"data"][@"Shop"][@"Name"] forKey:@"name"];
        }
        if (![[NSString stringWithFormat:@"%@", triggerDic[@"tags"]] isEqualToString:nil])
        {
            [self.graphic setAttribute:[NSString stringWithFormat:@"%@", triggerDic[@"tags"]] forKey:@"tags"];
        }
    }
    
    return self;
}

- (void)clearObject
{
    self.triggerID = @"";
    self.message = @"";
    self.shopName = @"";
    
    [self.tags removeAllObjects];
    [self.notifData removeAllObjects];
    [self.allPromotionsKeys removeAllObjects];
    [self.allPromotionsValues removeAllObjects];
}

@end
