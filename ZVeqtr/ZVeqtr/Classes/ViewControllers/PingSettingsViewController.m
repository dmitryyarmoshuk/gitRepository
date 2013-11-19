//
//  PingSettingsViewController_iPhone.m
//  Peek
//
//  Created by Pavel on 16.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "PingSettingsViewController.h"

@implementation PingSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	page1.center = CGPointMake(160, 270);
	[self.view addSubview:page1];
	
	[pickerPing selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPing_0"] inComponent:0 animated:YES];
	[pickerPing selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPing_1"] inComponent:1 animated:YES];
	[pickerPing selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPing_2"] inComponent:2 animated:YES];
	[pickerPing selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPing_3"] inComponent:3 animated:YES];
	
	[pickerPrivacy selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerPrivacy"] inComponent:0 animated:YES];

	[pickerDistance selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"pickerDistance"] inComponent:0 animated:YES];

	switchDistance.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"switchDistance"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	if (pickerView.tag == 100) {
		return 4;
	} else if (pickerView.tag == 101) {
		return 1;
	} else if (pickerView.tag == 102) {
		return 1;
	}
	
	return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	if (pickerView.tag == 100) {
		if (component == 0) {
			return 12;
		} else if (component == 1) {
			return 24;
		} else if (component == 2) {
			return 60;
		} else if (component == 3) {
			return 12;
		}
	} else if (pickerView.tag == 101) {
		return 2;
	} else if (pickerView.tag == 102) {
		return 7;
	}

	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if (pickerView.tag == 100) {
		if (component == 0) {
			return [NSString stringWithFormat:@"%d", row];
		} else if (component == 1) {
			return [NSString stringWithFormat:@"%d", row];
		} else if (component == 2) {
			return [NSString stringWithFormat:@"%d", row];
		} else if (component == 3) {
			return [NSString stringWithFormat:@"%d", row * 5];
		}
	} else if (pickerView.tag == 101) {
		if (row == 0) {
			return @"Everyone";
		} else {
			return @"Friends Only";
		}
	} else if (pickerView.tag == 102) {
		if (row == 0) {
			return @"<1 Mile";
		} else if (row == 1) {
			return @"5 Miles";
		} else if (row == 2) {
			return @"10 Miles";
		} else if (row == 3) {
			return @"25 Miles";
		} else if (row == 4) {
			return @"50 Miles";
		} else if (row == 5) {
			return @"100 Miles";
		} else {
			return @"150 Miles";
		}
		
	}
	
	return @"";
}

- (IBAction)segmentSelected:(UISegmentedControl *)segmented {

	if (segmented.selectedSegmentIndex == 0) {
		
		[page2 removeFromSuperview];
		[page3 removeFromSuperview];
		page1.center = CGPointMake(160, 270);
		[self.view addSubview:page1];
		
	} else if (segmented.selectedSegmentIndex == 1) {
		
		[page1 removeFromSuperview];
		[page3 removeFromSuperview];
		page2.center = CGPointMake(160, 270);
		[self.view addSubview:page2];
		
	} else if (segmented.selectedSegmentIndex == 2) {
			
		[page1 removeFromSuperview];
		[page2 removeFromSuperview];
		page3.center = CGPointMake(160, 270);
		[self.view addSubview:page3];
	
	}
}

- (IBAction)backPressed {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)savePressed {
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerPing selectedRowInComponent:0] forKey:@"pickerPing_0"];
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerPing selectedRowInComponent:1] forKey:@"pickerPing_1"];
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerPing selectedRowInComponent:2] forKey:@"pickerPing_2"];
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerPing selectedRowInComponent:3] forKey:@"pickerPing_3"];
	
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerPrivacy selectedRowInComponent:0] forKey:@"pickerPrivacy"];
	[[NSUserDefaults standardUserDefaults] setInteger:[pickerDistance selectedRowInComponent:0] forKey:@"pickerDistance"];
	
	[[NSUserDefaults standardUserDefaults] setBool:!switchDistance.on forKey:@"switchDistance"];
	
	[self backPressed];
}

@end
