//
//  HashBookmarksVC.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/16/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "HashBookmarksVC.h"

@interface HashBookmarksVC ()
@property (nonatomic, retain) IBOutlet UITableView *table;
//
@property (nonatomic, retain) NSArray *allHashtags;
@end


@implementation HashBookmarksVC

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
}

- (void)dealloc {
	self.allHashtags = nil;
	self.allDisabledHashtags = nil;
	[super dealloc];
}

+ (BOOL)hasBookmarks {
	return APP_DLG.currentUser.allHashtags.count > 0;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.allHashtags = APP_DLG.currentUser.allHashtags;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.table reloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.allHashtags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const NSUInteger row = indexPath.row;
	static NSString *cellID = @"cellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (! cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		
		UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
		if (font) {
			cell.textLabel.font = font;
		}
	}
	NSString *tag = [self.allHashtags objectAtIndex:row];
	cell.textLabel.text = tag;
	BOOL disabled = [self.allDisabledHashtags containsObject:tag];
	cell.textLabel.textColor = disabled ? [UIColor grayColor] : [UIColor blackColor];
	cell.selectionStyle = disabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSString *tag = [self.allHashtags objectAtIndex:indexPath.row];
	BOOL disabled = [self.allDisabledHashtags containsObject:tag];
	if (!disabled) {
		[self.delegate hashBookmarksVC:self didSelectTagString:tag];
	}
}

@end
