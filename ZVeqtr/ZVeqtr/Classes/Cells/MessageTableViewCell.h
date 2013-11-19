//
//  MessageTableViewCell.h
//  Peek
//
//  Created by Pavel on 23.12.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;

@interface MessageTableViewCell : UITableViewCell {
	IBOutlet UILabel *labelText;
	IBOutlet EGOImageView *imageUser;
	
}

- (void)updateCell:(NSDictionary *)dic;

@end
