//
//  ZTaggedButton.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/17/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZTaggedButton.h"


@interface ZTaggedButton ()
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) NSInvocation *invocation;
@end


@implementation ZTaggedButton

- (void)dealloc
{
	self.userInfo = nil;
	self.button = nil;
	[super dealloc];
}


+ (ZTaggedButton *)buttonWithTarget:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	ZTaggedButton *taggedButton = [[self new] autorelease];
	
	[btn addTarget:taggedButton action:@selector(performAction) forControlEvents:UIControlEventTouchUpInside];
    
	taggedButton.frame = btn.frame;
	[taggedButton addSubview:btn];
	taggedButton.backgroundColor = [UIColor clearColor];
    
	taggedButton.button = btn;
	
	NSMethodSignature *sig = [target methodSignatureForSelector:action];
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
	inv.target = target;
	inv.selector = action;
	[inv setArgument:&taggedButton atIndex:2];
	
	taggedButton.invocation = inv;
	
	return taggedButton;
}

- (void)performAction
{
	[self.invocation invoke];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p> userInfo:'%@'",
			[self class], self, self.userInfo];
}

@end
