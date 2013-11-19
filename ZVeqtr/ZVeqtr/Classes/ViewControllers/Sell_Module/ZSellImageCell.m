//
//  ZSellImageCell.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSellImageCell.h"
#import <QuartzCore/QuartzCore.h>

@interface ZSellImageCell()

@property (nonatomic, retain) IBOutlet UIView *picBack;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ZSellImageCell

- (void)awakeFromNib
{
    /*
     UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
     if (font) 
     {
        _labTitle.font = font;
        _labNickname.font = font;
     
        _picBack.layer.masksToBounds = YES;
        _picBack.layer.cornerRadius = 4;
        _picBack.layer.borderColor = [UIColor grayColor].CGColor;
        _picBack.layer.borderWidth = 1;
     }
     */
    
    self.picBack.layer.masksToBounds = YES;
    self.picBack.layer.cornerRadius = 4;
    self.picBack.layer.borderColor = [UIColor grayColor].CGColor;
    self.picBack.layer.borderWidth = 1;
    
    self.cellImageView.delegate = self;
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.activityIndicator stopAnimating];
}

+ (ZSellImageCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(void)updateWithSellImage:(ZSellImageModel*)model
{
    self.buttonRemoveImage.enabled = model && !model.isDeleted;
    
    if(model.isDeleted)
    {
        self.cellImageView.image = nil;
    }
    else if(model.image)
    {
        self.cellImageView.image = model.image;
    }
    else if(model)
    {
        [self.activityIndicator startAnimating];
        self.cellImageView.imageURL = [NSURL urlSaleImageFull:model.urlString];
    }
}

- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    [self.activityIndicator stopAnimating];
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    [self.activityIndicator stopAnimating];
    
    [APP_DLG showAlertWithMessage:error.localizedDescription title:nil];
}

@end
