//
//  ZFavoriteCell.m
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZFavoriteCell.h"

@interface ZFavoriteCell()

@property (nonatomic, retain) UIButton *imageButton;

@end

@implementation ZFavoriteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.filterImage = [[[EGOImageView alloc] init] autorelease];
        [self.contentView addSubview:self.filterImage];
        
        self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageButton addTarget:self action:@selector(pictureButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.imageButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    int imageSize = 50;
    int textLeftOffset = 10;
    int buttonOffset = 10;
    
    self.imageButton.frame = CGRectMake(self.contentView.bounds.size.width - imageSize - buttonOffset, (self.contentView.bounds.size.height - imageSize)/2, imageSize, imageSize);
    self.filterImage.frame = self.imageButton.frame;
    
    self.textLabel.frame = CGRectMake(textLeftOffset, 10, self.contentView.bounds.size.width - imageSize - buttonOffset*2 - textLeftOffset, 20);
    self.detailTextLabel.frame = CGRectMake(textLeftOffset, 30, self.contentView.bounds.size.width - imageSize - buttonOffset*2 - textLeftOffset, 30);
}

-(void)pictureButtonClicked
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(pictureButtonClickedInCell:)])
    {
        [self.delegate pictureButtonClickedInCell:self];
    }
}

-(void)dealloc
{
    self.delegate = nil;
    self.imageButton = nil;
    
    [super dealloc];
}

@end
