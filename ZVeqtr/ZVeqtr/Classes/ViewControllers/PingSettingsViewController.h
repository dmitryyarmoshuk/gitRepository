//
//  PingSettingsViewController_iPhone.h
//  Peek
//
//  Created by Pavel on 16.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"


@interface PingSettingsViewController : ZSuperViewController
{
	IBOutlet UIView *page1;
	IBOutlet UIView *page2;
	IBOutlet UIView *page3;
	
	IBOutlet UIPickerView *pickerPing;
	IBOutlet UIPickerView *pickerPrivacy;
	IBOutlet UIPickerView *pickerDistance;
	
	IBOutlet UISwitch *switchDistance;
}

- (IBAction)segmentSelected:(UISegmentedControl *)segmented;
- (IBAction)backPressed;
- (IBAction)savePressed;

@end
