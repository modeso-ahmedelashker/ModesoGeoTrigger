//
//  User.h
//  ModesoGeotrigger
//
//  Created by Modeso on 2/3/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *deviceID;
@property (strong, nonatomic) NSString *deviceLastSeen;
@property (strong, nonatomic) NSString *deviceTrackingProfile;
@property (strong, nonatomic) NSMutableSet *deviceTags;

@property (strong, nonatomic) NSMutableSet *userTags;

@end
