//
//  ZSaleImagesTable.h
//  ZVeqtr
//
//  Created by Maxim on 4/7/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSellImageModel;

@protocol ZSaleImagesTableDelegate;

@interface ZSaleImagesTable : UIView

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) id<ZSaleImagesTableDelegate> delegate;

-(void)reloadImages:(NSMutableArray*)garageSaleImages;

@end

@protocol ZSaleImagesTableDelegate <NSObject>
@required
-(void)table:(ZSaleImagesTable*)table didSelectImage:(ZSellImageModel*)imageModel;

@end