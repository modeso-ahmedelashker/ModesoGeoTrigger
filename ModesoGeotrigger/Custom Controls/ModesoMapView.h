//
//  ModesoMapView.h
//  ModesoGeotrigger
//
//  Created by Modeso on 2/18/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface ModesoMapView : AGSMapView <AGSMapViewTouchDelegate, AGSMapViewLayerDelegate, AGSCalloutDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

// Current location and point objects
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastLocation;
@property (strong, nonatomic) AGSPoint *currentMapPoint;
@property (strong, nonatomic) AGSGraphic *currentMapPointGraphic;
@property (strong, nonatomic) AGSGraphicsLayer *currentPointLayer;
@property (strong, nonatomic) AGSSimpleMarkerSymbol *markerSymbol;

// Selected, unselected and tag related trigger data
@property (strong, nonatomic) NSMutableArray *allTriggersDics;
@property (strong, nonatomic) AGSGraphicsLayer *selectedTriggersLayer;
@property (strong, nonatomic) AGSGraphicsLayer *unselectedTriggersLayer;
@property (strong, nonatomic) AGSSimpleFillSymbol *selectedFillSymbol;
@property (strong, nonatomic) AGSSimpleFillSymbol *unselectedFillSymbol;
@property (strong, nonatomic) AGSSimpleRenderer *selectedRenderer;
@property (strong, nonatomic) AGSSimpleRenderer *unselectedRenderer;

// Map's callout table
@property (strong, nonatomic) UITableView *tableCallout;

@end
