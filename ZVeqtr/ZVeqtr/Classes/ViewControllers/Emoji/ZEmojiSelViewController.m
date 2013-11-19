//
//  ZEmojiSelViewController.m
//  ZVeqtr
//
//  Created by Leonid Lo on 1/9/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZEmojiSelViewController.h"
#import "ZEmojiCell.h"


@interface ZEmojiSelViewController ()
<UITableViewDataSource, UITableViewDelegate, ZEmojiCellDelegate>
@property (nonatomic, retain) IBOutlet	UITableView		*table;
@property (nonatomic, retain) NSArray	*allSymbols;
@end


@implementation ZEmojiSelViewController


static NSString *AllEmojiesString =
@"\ue415\ue056\ue057\ue414\ue405\ue106\ue418"
@"\ue417\ue40d\ue40a\ue404\ue105\ue409\ue40e"
@"\ue402\ue108\ue403\ue058\ue407\ue401\ue40f"
@"\ue40b\ue406\ue413\ue411\ue412\ue410\ue107"
@"\ue059\ue416\ue408\ue40c\ue11a\ue10c\ue32c"
@"\ue32a\ue32d\ue328\ue32b\ue022\ue023\ue327"
;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:32];
	int i=0, j;
	while (i < AllEmojiesString.length) {
		NSMutableArray *subarray = [NSMutableArray arrayWithCapacity:8];
		[arr addObject:subarray];
		for (j = 0; j<5 && i < AllEmojiesString.length; ++j, ++i) {
			NSString *symbol = [AllEmojiesString substringWithRange:NSMakeRange(i, 1)];
			[subarray addObject:symbol];
		}
		for (; j<5; ++j) {
			//	adding empty strings
			[subarray addObject:@""];
		}
	}
	
	self.allSymbols = arr;
	[self.table reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.allSymbols.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"ZEmojiCell";
	ZEmojiCell *cell = [self.table dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [ZEmojiCell cell];
		cell.delegate = self;
	}
	NSArray *subarray = self.allSymbols[indexPath.row];
	[cell.btn0 setTitle:subarray[0] forState:UIControlStateNormal];
	[cell.btn1 setTitle:subarray[1] forState:UIControlStateNormal];
	[cell.btn2 setTitle:subarray[2] forState:UIControlStateNormal];
	[cell.btn3 setTitle:subarray[3] forState:UIControlStateNormal];
	[cell.btn4 setTitle:subarray[4] forState:UIControlStateNormal];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ZEmojiCellDelegate

- (void)emojiCell:(ZEmojiCell *)emojiCell didSelectSymbol:(NSString *)strSymbol
{
	NSLog(@"%@", strSymbol);
	[self.delegate emojiSelViewController:self didSelectSymbol:strSymbol];
}

@end
