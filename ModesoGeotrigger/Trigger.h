//
//  TriggerModel.h
//  ModesoGeotrigger
//
//  Created by Modeso on 2/3/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface Trigger : NSObject

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *direction;
@property (strong, nonatomic) NSMutableDictionary *notifData;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) AGSGraphic *graphic;
@property (assign, nonatomic) int rateLimit;
@property (assign, nonatomic) int times;
@property (strong, nonatomic) NSString *triggerID;
@property (strong, nonatomic) NSMutableArray *allPromotionsKeys;
@property (strong, nonatomic) NSMutableArray *allPromotionsValues;
@property (strong, nonatomic) NSString *shopName;

- (id)initWithDictionary:(NSDictionary *)triggerDic GeoEngine:(AGSGeometryEngine *)geoEngine SpatialReference:(AGSSpatialReference *)spatialReference;

- (void)clearObject;

@end
