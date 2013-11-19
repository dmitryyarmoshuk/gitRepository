//
//  ZSaleImagesTable.m
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSaleImagesTable.h"
#import <QuartzCore/QuartzCore.h>

#import "ZSellImageModel.h"
#import "EGOImageView.h"

@interface SaleImageButton : UIButton

@property (nonatomic, assign) ZSellImageModel *sellImageModel;

@end

@implementation SaleImageButton

@end

@interface ZSaleImagesTable()

@property (nonatomic, strong) NSMutableArray *imageViews;

@end

#define activityIndicatorTag 13

@implementation ZSaleImagesTable

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.imageSize = CGSizeMake(90, 90);
        
        self.imageViews = [NSMutableArray array];
    }
    
    return self;
}

-(void)awakeFromNib
{
    self.imageSize = CGSizeMake(90, 90);
    
    self.imageViews = [NSMutableArray array];
}

-(void)clearAllImages
{
    for(UIView *v in self.imageViews)
    {
        [v removeFromSuperview];
    }
    
    [self.imageViews removeAllObjects];
}

-(void)addImageViewWithFrame:(CGRect)frame imageModel:(ZSellImageModel*)imageModel
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.tag = activityIndicatorTag;
    activityIndicator.hidesWhenStopped = YES;
    [view addSubview:activityIndicator];
    [activityIndicator stopAnimating];
    
    [self addSubview:view];
    [self.imageViews addObject:view];
    
    EGOImageView *imview = [[EGOImageView alloc] initWithFrame:view.bounds];
    if(imageModel.image)
    {
        imview.image = imageModel.image;
    }
    else
    {
        [activityIndicator startAnimating];
        imview.imageURL = [NSURL urlSaleImageFull:imageModel.urlString];
    }
    
    [view addSubview:imview];
    
    if([imageModel.status boolValue])
    {
        EGOImageView *soldIm = [[EGOImageView alloc] initWithFrame:view.bounds];
        soldIm.image = [UIImage imageNamed:@"sold_icon"];
        [view addSubview:soldIm];
    }
    else
    {
        SaleImageButton *button = [SaleImageButton buttonWithType:UIButtonTypeCustom];
        button.frame = view.bounds;
        button.sellImageModel = imageModel;
        [button addTarget:self action:@selector(imagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
}

-(void)reloadImages:(NSMutableArray*)garageSaleImages
{
    [self clearAllImages];
    
    const int initialHorizontalOffset = 15;
    const int distanceBetweenImages = 10;
    const int initialVerticalOffset = 0;
    
    
    int curretnVerticalOffset = initialVerticalOffset;
    int currentHorizontalOffset = initialHorizontalOffset;
    
    for(ZSellImageModel *imageModel in garageSaleImages)
    {
        CGRect frame = CGRectMake(currentHorizontalOffset, curretnVerticalOffset, self.imageSize.width, self.imageSize.height);
        
        [self addImageViewWithFrame:frame imageModel:imageModel];
        
        {
            //set container view size
            CGRect currentFrame = self.frame;
            currentFrame.size.height = frame.origin.y + frame.size.height + initialVerticalOffset;
            self.frame = currentFrame;
        }

        currentHorizontalOffset += frame.size.width + distanceBetweenImages;
        if(currentHorizontalOffset + self.imageSize.width > self.frame.size.width)
        {
            currentHorizontalOffset = initialHorizontalOffset;
            curretnVerticalOffset += self.imageSize.height + distanceBetweenImages;
        }
    }
}

-(void)imagePressed:(SaleImageButton*)sender
{
    if(self.delegate)
        [self.delegate table:self didSelectImage:sender.sellImageModel];
}

- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[imageView.superview viewWithTag:activityIndicatorTag];
    [activityIndicator stopAnimating];
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[imageView.superview viewWithTag:activityIndicatorTag];
    [activityIndicator stopAnimating];
    
    [APP_DLG showAlertWithMessage:error.localizedDescription title:nil];
}

@end
