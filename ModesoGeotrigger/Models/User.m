//
//  User.m
//  ModesoGeotrigger
//
//  Created by Modeso on 2/3/16.
//  Copyright © 2016 Modeso. All rights reserved.
//

#import "User.h"

@implementation User

- (id)init
{
    self = [super init];
    
    if (self)
    {
        if (self.deviceTags == nil)
        {
            self.deviceTags = [NSMutableSet set];
        }
        if (self.userTags == nil)
        {
            self.userTags = [NSMutableSet set];
        }
    }
    
    return self;
}

@end
