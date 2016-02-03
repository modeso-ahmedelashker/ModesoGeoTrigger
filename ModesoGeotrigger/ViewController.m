//
//  ViewController.m
//  ModesoGeotrigger
//
//  Created by Modeso on 1/29/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tableCallout;

// Graphical Objects
@synthesize selectedRenderer, selectedFillSymbol, unselectedRenderer, unselectedFillSymbol, selectedTriggersLayer, unselectedTriggersLayer, currentPointLayer, currentMapPoint, currentMapPointGraphic, markerSymbol;

// Class Data
@synthesize allTriggersDics, currentAreaTags, geoEngine, globalSR, lastLocation, firedDict, allPromotionsKeys, allPromotionsValues, selectedShopName, locationBtnTapped, currentUser, userTags;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Custom initialization
    
    // Init values
    lastLocation = nil;
    globalSR = nil;
    locationBtnTapped = NO;
    
    if (currentUser == nil)
    {
        currentUser = [[User alloc] init];
    }
    
    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushNotificationReceived)
                                                 name:@"pushNotificationReceived"
                                               object:nil];
    
    _mapView.touchDelegate = self;
    _mapView.callout.delegate = self;
    _mapView.layerDelegate = self;
    
    //------------------------------Load base layer-------------------------------------
    NSURL *mapUrl = [NSURL URLWithString:@"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer"];
    AGSTiledMapServiceLayer *tiledLyr = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:mapUrl];
    
    [_mapView addMapLayer:tiledLyr withName:@"Base Map"];
    
    //-------------------------------Load Location------------------------------------
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    lastLocation = locations.lastObject;
      
    if (globalSR != nil && locationBtnTapped)
    {
        [self drawLocationPointOnEnvelope:nil];
    }
    
    // Send location to webservice with refresh token
    NSString *refreshToken = [[[AGSGTGeotriggerManager sharedManager] valueForKey:@"device"] valueForKey:@"refreshToken"];
    
    NSString *lon = [NSString stringWithFormat:@"%f", lastLocation.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f", lastLocation.coordinate.latitude];
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.12.33:3000/wines"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString *postStr = [NSString stringWithFormat:@"lon=%@&lat=%@&token=%@",lon, lat, refreshToken];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postStr length]];
    
    [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         
     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AGSMapViewTouchDelegate methods

- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    //-----------------------------[1] Init map data----------------------------------
    if (allTriggersDics == nil)
    {
        allTriggersDics = [NSMutableArray array];
    }
    if (firedDict == nil)
    {
        firedDict = [NSMutableDictionary dictionary];
    }
    if (userTags == nil)
    {
        userTags = [NSMutableSet set];
    }
    if (currentAreaTags == nil)
    {
        currentAreaTags = [NSMutableSet set];
    }
    if (allPromotionsKeys == nil)
    {
        allPromotionsKeys = [NSMutableArray array];
    }
    if (allPromotionsValues == nil)
    {
        allPromotionsValues = [NSMutableArray array];
    }
    
    //-----------------------------[2] Init map UI objects----------------------------
    if (geoEngine == nil)
    {
        geoEngine = [[AGSGeometryEngine alloc] init];
    }
    if (selectedFillSymbol == nil)
    {
        selectedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        selectedFillSymbol.color = [[UIColor greenColor] colorWithAlphaComponent:0.25];
    }
    if (unselectedFillSymbol == nil)
    {
        unselectedFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        unselectedFillSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.25];
    }
    if (selectedRenderer == nil)
    {
        selectedRenderer = [[AGSSimpleRenderer alloc] initWithSymbol:selectedFillSymbol];
    }
    if (unselectedRenderer == nil)
    {
        unselectedRenderer = [[AGSSimpleRenderer alloc] initWithSymbol:unselectedFillSymbol];
    }
    if (markerSymbol == nil)
    {
        markerSymbol = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
        markerSymbol.style = AGSSimpleMarkerSymbolStyleDiamond;
        markerSymbol.color = [UIColor redColor];
    }
    if (currentMapPoint == nil)
    {
        currentMapPoint = [[AGSPoint alloc] init];
    }
    if (currentMapPointGraphic == nil)
    {
        currentMapPointGraphic = [[AGSGraphic alloc] init];
    }
    
    //---------------------------[3] Init graphical layers---------------------------------
    currentPointLayer = [AGSGraphicsLayer graphicsLayer];
    selectedTriggersLayer = [AGSGraphicsLayer graphicsLayer];
    unselectedTriggersLayer = [AGSGraphicsLayer graphicsLayer];
    
    currentPointLayer.allowLayerConsolidation = NO;
    selectedTriggersLayer.allowLayerConsolidation = NO;
    unselectedTriggersLayer.allowLayerConsolidation = NO;
    
    selectedTriggersLayer.renderer = selectedRenderer;
    unselectedTriggersLayer.renderer = unselectedRenderer;
    
    [mapView addMapLayer:currentPointLayer withName:@"Point Graphics Layer"];
    [mapView addMapLayer:selectedTriggersLayer withName:@"Selected Triggers Layer"];
    [mapView addMapLayer:unselectedTriggersLayer withName:@"Unselected Triggers Layer"];
    
    //---------------------------[4] Get global SR-----------------------------------------
    globalSR = mapView.spatialReference;
    
    [self retrievePlacesWithSelectedTags:nil];
}

- (void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    // Features is a layer-key based dictionary
    NSArray *oneKeyArr = features.allKeys;
    
    if (oneKeyArr.count > 0)
    {
        // Clear promotions data for new result
        [allPromotionsKeys removeAllObjects];
        [allPromotionsValues removeAllObjects];
        
        // Get every Features->Layer->Graphic->Attributes->Data->Shop->Promotions->Dictionary
        // Looping in case of clicking on an multiple-layered area
        for (int i = 0; i < oneKeyArr.count; i++)
        {
            // 1- Get graphics json array from the first non-point layer
            NSArray *allJsonGraphics = features.allValues[i];
            
            // 2- Always get the first graph of the graphics json array
            AGSGraphic *recievedTrigger = allJsonGraphics[0];
            
            // 3- Check if graph attributes has data
            NSString *tempStr = [recievedTrigger attributeForKey:@"data"];
            
            if (![tempStr isKindOfClass:[NSNull class]])
            {
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
            else // Current point graph touched = No data
            {
                [mapView.callout dismiss];
                
                continue;
            }
            
            // Set callout, set table, reload table, set table as callout view and show callout
            [mapView.callout setFrame:CGRectMake(mappoint.x, mappoint.y, 300, 150)];
            
            if (tableCallout == nil)
            {
                tableCallout = [[UITableView alloc] initWithFrame:_mapView.callout.frame];
                tableCallout.dataSource = self;
                tableCallout.delegate = self;
            }
            
            [tableCallout reloadData];
            
            [mapView.callout setCustomView:tableCallout];
            
            [mapView.callout showCalloutAtPoint:mappoint forFeature:recievedTrigger layer:nil animated:YES];
            
            break;
        }
    }
    else
        [mapView.callout dismiss];
}

- (void)retrievePlacesWithSelectedTags:(NSMutableSet*)loadedTags
{
    userTags = [NSMutableSet setWithSet:currentUser.userTags];
    
    [self drawTriggersWithParamsDictionary:nil andSelectedTags:loadedTags];
}

- (void)pushNotificationReceived
{
    NSMutableDictionary *ShopDic = firedDict[@"Shop"];
    
    for (AGSGraphic *graphic in selectedTriggersLayer.graphics)
    {
        if ([[graphic attributeForKey:@"name"] isEqualToString:ShopDic[@"Name"]])
        {
            [_mapView zoomToEnvelope:[self envelopeFromGeometry:graphic.geometry] animated:YES];
        }
    }
}

- (void)drawTriggersWithParamsDictionary:(NSDictionary*)params andSelectedTags:(NSMutableSet*)loadedTags
{
    if (params == nil)
    {
        params = @{@"geoFormat": @"esrijson"};
    }
    
    [[AGSGTApiClient sharedClient] postPath:@"trigger/list"
                                 parameters:params
                                    success:^(id responseObject)
     {
         if (responseObject != nil)
         {
             [self clearData];
             
             if ([loadedTags isKindOfClass:[NSMutableSet class]])
             {
                 currentAreaTags = loadedTags;
             }
             
             // Create scan envelope
             AGSMutableEnvelope *containerEnvelope = [[AGSMutableEnvelope alloc] init];
             
             allTriggersDics = [NSMutableArray arrayWithArray:responseObject[@"triggers"]];
             
             for (NSDictionary *trigger in allTriggersDics)
             {
                 // Make a TM instance for easy use
                 Trigger *TM = [[Trigger alloc] initWithDictionary:trigger GeoEngine:geoEngine SpatialReference:globalSR];
                 
                 // Load all tags to currentAreaTags if not value
                 if (loadedTags == nil || [loadedTags isKindOfClass:[NSNotification class]])
                     [currentAreaTags addObjectsFromArray:TM.tags];
                 
                 // Add Trigger to envelope
                 [containerEnvelope unionWithEnvelope:[self envelopeFromGeometry:TM.graphic.geometry]];
                 
                 // Add TM to either selected or unselected layer depending on matched tags
                 for (NSString* tag in TM.tags)
                 {
                     if ([userTags containsObject:tag])
                         [selectedTriggersLayer addGraphic:TM.graphic];
                     else
                         [unselectedTriggersLayer addGraphic:TM.graphic];
                     
                     // Collect zoom envelope for tags matching current data only, if any
                     if ([currentAreaTags containsObject:tag])
                         [containerEnvelope unionWithEnvelope:[self envelopeFromGeometry:TM.graphic.geometry]];
                 }
                 
                 // If not, collect all
                 if (currentAreaTags == nil)
                     [containerEnvelope unionWithEnvelope:[self envelopeFromGeometry:TM.graphic.geometry]];
             }
             
             if (locationBtnTapped)
             {
                 [self drawLocationPointOnEnvelope:containerEnvelope];
             }
             
             [_mapView zoomToEnvelope:containerEnvelope animated:YES];
         }
     }
                                    failure:^(NSError *error)
     {
         
     }];
}

- (void)clearData
{
    // Clear all trigger layers and dictionaries
    [allTriggersDics removeAllObjects];
    [currentAreaTags removeAllObjects];
    [selectedTriggersLayer removeAllGraphics];
    [unselectedTriggersLayer removeAllGraphics];
}

- (AGSMutableEnvelope *)envelopeFromGeometry:(AGSGeometry *)incomingGeometry
{
    AGSMutableEnvelope *newEnv = [AGSMutableEnvelope envelopeWithXmin:incomingGeometry.envelope.xmin ymin:incomingGeometry.envelope.ymin xmax:incomingGeometry.envelope.xmax ymax:incomingGeometry.envelope.ymax spatialReference:incomingGeometry.spatialReference];
    
    [newEnv expandByFactor:1.25];
    
    return newEnv;
}

- (void)drawLocationPointOnEnvelope:(AGSMutableEnvelope*)receivedEnv
{
    currentMapPoint = [AGSPoint pointWithLocation:lastLocation];
    
    currentMapPointGraphic = [AGSGraphic graphicWithGeometry:[geoEngine projectGeometry:currentMapPoint toSpatialReference:globalSR] symbol:markerSymbol attributes:nil];
    
    [currentPointLayer removeAllGraphics];
    [currentPointLayer addGraphic:currentMapPointGraphic];
    
    [selectedTriggersLayer refresh];
    [unselectedTriggersLayer refresh];
    
    if (receivedEnv == nil)
    {
        [_mapView zoomToScale:5000 withCenterPoint:currentMapPoint animated:YES];
    }
    else
    {
        [receivedEnv unionWithEnvelope:[self envelopeFromGeometry:((AGSGraphic*)currentPointLayer.graphics[0]).geometry]];
        
        [_mapView zoomToEnvelope:receivedEnv animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tableCallout)
    {
        return 1 + allPromotionsKeys.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell %ld", (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
        cell.textLabel.text = selectedShopName;
    else
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", allPromotionsKeys[indexPath.row - 1], allPromotionsValues[indexPath.row - 1]];
    
    return cell;
}
@end
