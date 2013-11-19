//
//  ZImageViewerController.m
//  ZVeqtr
//
//  Created by Maxim on 2/5/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZImageViewerController.h"

@interface ZImageViewerController ()

@property (nonatomic, retain) IBOutlet EGOImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;


@end

@implementation ZImageViewerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = @"Large Picture";
    [self presentBackBarButtonItem];
    [self presentSaveBarButtonItem];
    
    [self.scrollView setCanCancelContentTouches:NO];
    
    self.scrollView.maximumZoomScale = 4.0;
    self.scrollView.minimumZoomScale = 0.25;
    
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.delegate = self;
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(actImageLongPress:)];
    recognizer.minimumPressDuration = 1;
    recognizer.delegate = self;
    [self.imageView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageView addGestureRecognizer:doubleTap     ];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    self.imageView.delegate = self;
    self.imageView.imageURL = self.imageUrl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleDoubleTap:(UIGestureRecognizer *)sender
{
    if(self.scrollView.zoomScale == 4)
    {
        [self.scrollView setZoomScale:1 animated:YES];
    }
    else
    {
        [self.scrollView setZoomScale:4 animated:YES];
    }
}

- (IBAction)actImageLongPress:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Save Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", nil];
        [sheet showInView:self.view];
        [sheet release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		return;
	}
	
	if(buttonIndex == 0)
    {
        //save image
        [self actSave];
    }
}

- (IBAction)actSave
{
	UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void) image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo;
{
    if(!error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Image was successfully saved to Photo Library" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)dealloc
{
    self.imageUrl = nil;
    
	[super dealloc];
}

- (void)releaseOutlets {
	[super releaseOutlets];
	self.imageView = nil;
    self.scrollView = nil;
}

-(CGSize)scaleSize:(CGSize)size toFitWidth:(int)width fitHeight:(int)height
{
    double koefWidth = 1;
    double koefHeight = 1;
    double resultKoef = 1;
    if(size.width > width)
    {
        koefWidth = size.width/width;
    }
    
    if(size.height > height)
    {
        koefHeight = size.height/height;
    }
    
    resultKoef = koefHeight > koefWidth ? koefHeight : koefWidth;
    
    return CGSizeMake(size.width/resultKoef, size.height/resultKoef);
}

- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    NSLog(@"%@", NSStringFromCGSize(imageView.image.size));
    NSLog(@"%@", NSStringFromCGSize(self.scrollView.frame.size));
        
    CGSize scaledSize = [self scaleSize:imageView.image.size toFitWidth:self.scrollView.frame.size.width fitHeight:self.scrollView.frame.size.height];
    
    self.scrollView.contentSize = scaledSize;
    CGPoint imageViewOrigin;
    
    if(imageView.image.size.height < self.scrollView.frame.size.height)
    {
        imageViewOrigin.y = (self.scrollView.frame.size.height - scaledSize.height)/2;
    }
    if(imageView.image.size.width < self.scrollView.frame.size.width)
    {
        imageViewOrigin.x = (self.scrollView.frame.size.width - scaledSize.width)/2;
    }
    
    self.imageView.frame = CGRectMake(imageViewOrigin.x, imageViewOrigin.y, scaledSize.width, scaledSize.height);
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    LLog(@"Failed to load image");
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

#pragma mark - UIGesture Recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

@end
