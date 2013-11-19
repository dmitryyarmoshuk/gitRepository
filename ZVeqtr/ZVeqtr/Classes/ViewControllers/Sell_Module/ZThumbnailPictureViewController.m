//
//  ZThumbnailPictureViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZThumbnailPictureViewController.h"


@interface ZThumbnailPictureViewController ()

@property (nonatomic, strong) IBOutlet EGOImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end

@implementation ZThumbnailPictureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self presentBackBarButtonItem];
    [self presentSaveBarButtonItem];
    
    self.imageView.delegate = self;
    
    if(self.garageSaleModel.thumbnailImage)
    {
        self.imageView.image = self.garageSaleModel.thumbnailImage;
        
        [self adjustImageContainer];
    }
    else
    {
        NSLog(@"%@", [NSURL urlSaleThumbnail:self.garageSaleModel.thumbnail]);
        self.imageView.imageURL = [NSURL urlSaleThumbnail:self.garageSaleModel.thumbnail];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustImageContainer
{
    CGPoint imageViewOrigin;
    
    if(self.imageView.image.size.height < self.scrollView.frame.size.height)
    {
        imageViewOrigin.y = (self.scrollView.frame.size.height - self.imageView.image.size.height)/2;
    }
    if(self.imageView.image.size.width < self.scrollView.frame.size.width)
    {
        imageViewOrigin.x = (self.scrollView.frame.size.width - self.imageView.image.size.width)/2;
    }
    
    self.scrollView.contentSize = self.imageView.image.size;
    
    self.imageView.frame = CGRectMake(imageViewOrigin.x, imageViewOrigin.y, self.imageView.image.size.width, self.imageView.image.size.height);
}

- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    NSLog(@"%@", NSStringFromCGSize(imageView.image.size));
    
    [self adjustImageContainer];
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    [APP_DLG showAlertWithMessage:[error localizedDescription] title:@"Failed to load thumbnail image"];
    
    [self adjustImageContainer];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

#pragma mark - Events

-(void)actSave
{
    [self.delegate controller:self shouldSaveImage:self.imageView.image];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)savePicture:(UIImage *)picture
{
    self.imageView.image = [picture scaleAndRotate];
    [self adjustImageContainer];
}

- (IBAction)actClearImage
{
    //[self takePicture];
    self.imageView.image = nil;
}

- (IBAction)actTakePicture
{
    [self takePicture];
}

@end
