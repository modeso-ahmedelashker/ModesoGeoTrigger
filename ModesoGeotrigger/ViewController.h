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
#import "ModesoMapView.h"
#import "User.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet ModesoMapView *mapView;

@end

