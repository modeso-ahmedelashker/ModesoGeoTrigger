//
//  ModesoMapView.m
//  ModesoGeotrigger
//
//  Created by Modeso on 2/18/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "ModesoMapView.h"
#import "Trigger.h"
#import "GISOperations.h"

#import <GeotriggerSDK/GeotriggerSDK.h>

@implementation ModesoMapView

- (void)awakeFromNib {
    
    [self setupItems];
    
    [self loadBaseLayer];
}

- (void)setupItems {
    
    _lastLocation = nil;
    
    if (_allTriggersDics == nil) {
        _allTriggersDics = [NSMutableArray array];
    }
    
    [self setupDelegates];
    
    [self setupLocationManager];
}

- (void)setupDelegates {
    
    self.touchDelegate = self;
    self.callout.delegate = self;
    self.layerDelegate = self;
}

- (void)setupLocationManager {
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)loadBaseLayer {
    
    NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
    
    [self addMapLayer:tiledLyr withName:@"Base Map"];
}

#pragma mark - MapView delegate
- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    [self setupMapUI];
    
    [self retrievePlacesWithSelectedTags:nil];
}

- (void)setupMapUI {
    
    [self setupLocationPoint];
    
    [self setupTriggers];
}

- (void)setupLocationPoint {
    
    if (_markerSymbol == nil) {
        _markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        _markerSymbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        _markerSymbol.color = [UIColor redColor];
    }
    
    if (_currentMapPoint == nil) {
        _currentMapPoint = [[AGSPoint alloc] init];
    }
    
    if (_currentMapPointGraphic == nil) {
        _currentMapPointGraphic = [[AGSGraphic alloc] init];
    }
    
    _currentPointLayer = [AGSGraphicsLayer graphicsLayer];
    _currentPointLayer.allowLayerConsolidation = NO;
    [self addMapLayer:_currentPointLayer withName:@"Point Graphics Layer"];
}

- (void)setupTriggers {
    
    [self setupSelectedTriggers];
    
    [self setupUnselectedTriggers];
}

- (void)setupSelectedTriggers {
    
    if (_selectedFillSymbol == nil) {
        _selectedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        _selectedFillSymbol.color = [[UIColor greenColor] colorWithAlphaComponent:0.25];
    }
    
    if (_selectedRenderer == nil) {
        _selectedRenderer = [[AGSSimpleRenderer alloc] initWithSymbol:_selectedFillSymbol];
    }
    
    _selectedTriggersLayer = [AGSGraphicsLayer graphicsLayer];
    _selectedTriggersLayer.allowLayerConsolidation = NO;
    _selectedTriggersLayer.renderer = _selectedRenderer;
    [self addMapLayer:_selectedTriggersLayer withName:@"Selected Triggers Layer"];
}

- (void)setupUnselectedTriggers {
    
    if (_unselectedFillSymbol == nil) {
        _unselectedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        _unselectedFillSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.25];
    }
    
    if (_unselectedRenderer == nil) {
        _unselectedRenderer = [[AGSSimpleRenderer alloc] initWithSymbol:_unselectedFillSymbol];
    }
    
    _unselectedTriggersLayer = [AGSGraphicsLayer graphicsLayer];
    _unselectedTriggersLayer.allowLayerConsolidation = NO;
    _unselectedTriggersLayer.renderer = _unselectedRenderer;
    [self addMapLayer:_unselectedTriggersLayer withName:@"Unselected Triggers Layer"];
}

- (void)retrievePlacesWithSelectedTags:(NSMutableSet*)loadedTags {
    
    [self drawTriggersWithParamsDictionary:nil andSelectedTags:loadedTags];
}

- (void)drawTriggersWithParamsDictionary:(NSDictionary*)params andSelectedTags:(NSMutableSet*)loadedTags
{
    if (params == nil) {
        params = @{@"geoFormat": @"esrijson"};
    }
    
    [[AGSGTApiClient sharedClient] postPath:@"trigger/list"
                                 parameters:params
                                    success:^(id responseObject) {
                                        if (responseObject != nil) {
                                            [self clearData];
                                            
                                            if ([loadedTags isKindOfClass:[NSMutableSet class]]) {
                                                //currentAreaTags = loadedTags;
                                            }
                                            
                                            // Create scan envelope
                                            AGSMutableEnvelope *containerEnvelope = [[AGSMutableEnvelope alloc] init];
                                            
                                            _allTriggersDics = [NSMutableArray arrayWithArray:responseObject[@"triggers"]];
                                            
                                            for (NSDictionary *trigger in _allTriggersDics)
                                            {
                                                // Make a TM instance for easy use
                                                Trigger *TM = [[Trigger alloc] initWithDictionary:trigger GeoEngine:[AGSGeometryEngine defaultGeometryEngine] SpatialReference:self.spatialReference];
                                                
                                                // Load all tags to currentAreaTags if not value
                                                //                 if (loadedTags == nil || [loadedTags isKindOfClass:[NSNotification class]])
                                                //                     [currentAreaTags addObjectsFromArray:TM.tags];
                                                
                                                // Add Trigger to envelope
                                                [containerEnvelope unionWithEnvelope:[GISOperations envelopeFromGeometry:TM.graphic.geometry]];
                                                
                                                // Add TM to either selected or unselected layer depending on matched tags
                                                for (NSString* tag in TM.tags) {
                                                    //                     if ([userTags containsObject:tag])
                                                    //                         [_selectedTriggersLayer addGraphic:TM.graphic];
                                                    //                     else
                                                    [_unselectedTriggersLayer addGraphic:TM.graphic];
                                                    
                                                    // Collect zoom envelope for tags matching current data only, if any
                                                    //                     if ([currentAreaTags containsObject:tag])
                                                    //                         [containerEnvelope unionWithEnvelope:[self envelopeFromGeometry:TM.graphic.geometry]];
                                                }
                                                
                                                // If not, collect all
                                                //if (currentAreaTags == nil)
                                                [containerEnvelope unionWithEnvelope:[GISOperations envelopeFromGeometry:TM.graphic.geometry]];
                                            }
                                            
                                            if (_lastLocation != nil) { // location is on?
                                                [self drawLocationPointOnEnvelope:containerEnvelope];
                                            }
                                            
                                            [self zoomToEnvelope:containerEnvelope animated:YES];
                                        }
                                    }
                                    failure:^(NSError *error)
     {
         
     }];
}

- (void)clearData {
    
    // Clear all trigger layers and dictionaries
    [_allTriggersDics removeAllObjects];
    //[currentAreaTags removeAllObjects];
    [_selectedTriggersLayer removeAllGraphics];
    [_unselectedTriggersLayer removeAllGraphics];
}

- (void)drawLocationPointOnEnvelope:(AGSMutableEnvelope*)receivedEnv {
    
    _currentMapPoint = [AGSPoint pointWithLocation:_lastLocation];
    
    _currentMapPointGraphic = [AGSGraphic graphicWithGeometry:[[AGSGeometryEngine defaultGeometryEngine] projectGeometry:_currentMapPoint toSpatialReference:self.spatialReference] symbol:_markerSymbol attributes:nil];
    
    [_currentPointLayer removeAllGraphics];
    [_currentPointLayer addGraphic:_currentMapPointGraphic];
    
    [_selectedTriggersLayer refresh];
    [_unselectedTriggersLayer refresh];
    
    if (receivedEnv == nil) {
        [self zoomToScale:5000 withCenterPoint:_currentMapPoint animated:YES];
    }
    else {
        [receivedEnv unionWithEnvelope:[GISOperations envelopeFromGeometry:((AGSGraphic*)_currentPointLayer.graphics[0]).geometry]];
        
        [self zoomToEnvelope:receivedEnv animated:YES];
    }
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    // Features is a layer-key based dictionary
    NSArray *oneKeyArr = features.allKeys;
    
    if (oneKeyArr.count > 0) {
        // Clear promotions data for new result
        //[allPromotionsKeys removeAllObjects];
        //[allPromotionsValues removeAllObjects];
        
        // Get every Features->Layer->Graphic->Attributes->Data->Shop->Promotions->Dictionary
        // Looping in case of clicking on an multiple-layered area
        for (int i = 0; i < oneKeyArr.count; i++) {
            // 1- Get graphics json array from the first non-point layer
            NSArray *allJsonGraphics = features.allValues[i];
            
            // 2- Always get the first graph of the graphics json array
            AGSGraphic *recievedTrigger = allJsonGraphics[0];
            
            // 3- Check if graph attributes has data
            NSString *tempStr = [recievedTrigger attributeForKey:@"data"];
            
            if (![tempStr isKindOfClass:[NSNull class]]) {
                // 4- Data dictionary
                NSDictionary *dict = [NSPropertyListSerialization
                                      propertyListWithData:[tempStr dataUsingEncoding:NSUTF8StringEncoding]
                                      options:kNilOptions
                                      format:NULL
                                      error:NULL];
                
                // TO DO
                // Further JSON structure
                //                // 5- Shop dictionary
                //                NSDictionary *shopDict = [dict objectForKey:@"Shop"];
                //                selectedShopName = [shopDict objectForKey:@"Name"];
                //
                //                // 6- Promotions array
                //                NSArray *promosArr = [NSArray arrayWithArray:[shopDict objectForKey:@"Promotions"]];
                //
                //                // 7- Promotion dictionary
                //                for (NSDictionary* promotion in promosArr)
                //                {
                //                    for (int i = 0; i < promotion.allKeys.count; i++)
                //                    {
                //                        [allPromotionsKeys addObject:promotion.allKeys[i]];
                //                        [allPromotionsValues addObject:promotion.allValues[i]];
                //                    }
                //                }
            }
            else { // Current point graph touched = No data
                [mapView.callout dismiss];
                
                continue;
            }
            
            // Set callout, set table, reload table, set table as callout view and show callout
            [mapView.callout setFrame:CGRectMake(mappoint.x, mappoint.y, 300, 150)];
            
            if (_tableCallout == nil) {
                _tableCallout = [[UITableView alloc] initWithFrame:mapView.callout.frame];
                _tableCallout.dataSource = self;
                _tableCallout.delegate = self;
            }
            
            [_tableCallout reloadData];
            
            [mapView.callout setCustomView:_tableCallout];
            
            [mapView.callout showCalloutAtPoint:mappoint forFeature:recievedTrigger layer:nil animated:YES];
            
            break;
        }
    }
    else
        [mapView.callout dismiss];
}

#pragma mark - Location manager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    _lastLocation = locations.lastObject;
    
    [self drawLocationPointOnEnvelope:nil];
}

#pragma mark - TableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    if (tableView == _tableCallout)
    //    {
    //        return 1 + allPromotionsKeys.count;
    //    }
    //    else
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %ld", (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    
    //    if (indexPath.row == 0)
    //        cell.textLabel.text = selectedShopName;
    //    else
    //        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", allPromotionsKeys[indexPath.row - 1], allPromotionsValues[indexPath.row - 1]];
    
    return cell;
}

@end
