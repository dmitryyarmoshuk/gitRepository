//
//  ZGeoplaceSelViewController.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/30/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZGeoplaceSelViewController.h"

@interface ZGeoplaceSelViewController ()
@property (nonatomic, retain) IBOutlet UITableView	*table;
@property (nonatomic, retain) IBOutlet UILabel		*labDescript;
@end


@implementation ZGeoplaceSelViewController

- (void)dealloc {
	self.message = nil;
	self.textInfo = nil;
	self.allGeoplaces = nil;
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.table = nil;
	self.labDescript = nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Select a Place";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	self.labDescript.text = self.message ? self.message :
		[NSString stringWithFormat:@"There are %d places available for your search. Please, select one", self.allGeoplaces.count];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.allGeoplaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"cellID";
	UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellID];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
		[cell autorelease];
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.font = [UIFont systemFontOfSize:14];
	}
	
	NSDictionary *dicZipPlace = self.allGeoplaces[indexPath.row];
	cell.textLabel.text = dicZipPlace[@"formatted_address"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.table deselectRowAtIndexPath:indexPath animated:YES];
	[self.delegate geoplaceSelViewController:self didSelectZipPlace:self.allGeoplaces[indexPath.row]];
}


@end
