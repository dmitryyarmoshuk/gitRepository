//
//  ZNewMessageModel.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/24/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZNewMessageModel.h"

@implementation ZNewMessageModel

- (void)dealloc {
	self.title = nil;
	self.message = nil;
	self.privacy = nil;
	self.imagePath = nil;
	self.sLatitude = nil;
	self.sLongitude = nil;
    
	[super dealloc];
}

- (BOOL)isValid {
	return self.title.length > 0;
}

@end
