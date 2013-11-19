//
//  ZCopyableCell.m
//  ZVeqtr
//
//  Created by Maxim on 3/11/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZCopyableCell.h"

static const CFTimeInterval kLongPressMinimumDurationSeconds = 1;

@implementation ZCopyableCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        return self;
    }
    
    [self initialize];
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void) initialize
{
    UIMenuItem *translateItem = [[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(translateAction:)];
    UIMenuItem *originalItem = [[UIMenuItem alloc] initWithTitle:@"Original" action:@selector(translateAction:)];
    [[UIMenuController sharedMenuController] setMenuItems: @[translateItem, originalItem]];
    [[UIMenuController sharedMenuController] update];
}

#pragma mark -
#pragma mark Copy Menu related methods

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(originalAction:) || action == @selector(translateAction:));
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

/// this methods will be called for the cell menu items
-(void) translateAction: (id) sender
{
    NSLog(@"translateAction");
}

-(void) originalAction: (id) sender
{
    NSLog(@"originalAction");
}

@end
