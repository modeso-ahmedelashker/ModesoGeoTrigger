//
//  ViewController.h
//  ModesoGeotrigger
//
//  Created by Modeso on 1/29/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import <GeotriggerSDK/GeotriggerSDK.h>
#import "Trigger.h"
#import "User.h"

@interface ViewController : UIViewController <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate, AGSCalloutDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet AGSMapView *mapView;

@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSMutableDictionary *firedDict;

@property (assign, nonatomic) BOOL locationBtnTapped;

// Current location and point objects
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableOrderedSet *locations;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) AGSPoint *currentMapPoint;
@property (strong, nonatomic) AGSGraphic *currentMapPointGraphic;
@property (strong, nonatomic) AGSGraphicsLayer *currentPointLayer;
@property (strong, nonatomic) AGSSimpleMarkerSymbol *markerSymbol;

// Spatial ref and geo engine
@property (strong, nonatomic) AGSSpatialReference *globalSR;
@property (strong, nonatomic) AGSGeometryEngine *geoEngine;

// Selected, unselected and tag related trigger data
@property (strong, nonatomic) NSMutableArray *allTriggersDics;
@property (strong, nonatomic) AGSGraphicsLayer *selectedTriggersLayer;
@property (strong, nonatomic) AGSGraphicsLayer *unselectedTriggersLayer;
@property (strong, nonatomic) AGSSimpleFillSymbol *selectedFillSymbol;
@property (strong, nonatomic) AGSSimpleFillSymbol *unselectedFillSymbol;
@property (strong, nonatomic) AGSSimpleRenderer *selectedRenderer;
@property (strong, nonatomic) AGSSimpleRenderer *unselectedRenderer;

// Highlighted trigger data for callout and detail text area
@property (strong, nonatomic) NSMutableArray *allPromotionsKeys;
@property (strong, nonatomic) NSMutableArray *allPromotionsValues;
@property (strong, nonatomic) NSString *selectedShopName;

// Main tags data
@property (strong, nonatomic) NSMutableSet *currentAreaTags;
@property (strong, nonatomic) NSMutableSet *userTags;

// Map's callout table
@property (strong, nonatomic) UITableView *tableCallout;

@end

