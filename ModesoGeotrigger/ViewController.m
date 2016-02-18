//
//  ViewController.m
//  ModesoGeotrigger
//
//  Created by Modeso on 1/29/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "ViewController.h"
#import "GISOperations.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushNotificationReceived:)
                                                 name:@"pushNotificationReceived"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushNotificationReceived:(NSDictionary*)notificationInfo
{
    NSMutableDictionary *ShopDic = notificationInfo[@"Shop"];
    
    for (AGSGraphic *graphic in _mapView.selectedTriggersLayer.graphics)
    {
        if ([[graphic attributeForKey:@"name"] isEqualToString:ShopDic[@"Name"]])
        {
            [_mapView zoomToEnvelope:[GISOperations envelopeFromGeometry:graphic.geometry] animated:YES];
        }
    }
}
@end
