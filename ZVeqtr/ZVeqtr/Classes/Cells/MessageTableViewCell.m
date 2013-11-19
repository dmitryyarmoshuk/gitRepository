//
//  MessageTableViewCell.m
//  Peek
//
//  Created by Pavel on 23.12.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "EGOImageView.h"

@implementation MessageTableViewCell

- (void)updateCell:(NSDictionary *)dic {
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font)
    {
		labelText.font = font;
	}
	labelText.text = [dic objectForKey:@"description"];
	
	imageUser.imageURL = [NSURL urlPersonProfileImageWithID:dic[@"user_id"]];
}

@end
