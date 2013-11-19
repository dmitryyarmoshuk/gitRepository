//
//  ZSellModuleImageDescriptionViewController.h
//  ZVeqtr
//
//  Created by Maxim on 4/5/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZSellImageModel.h"
#import "ZListPostCell.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


typedef enum
{
    ImageDescriptionScreenStateDefault,
    ImageDescriptionScreenStateEdit,
    ImageDescriptionScreenStatePreview
} ImageDescriptionScreenState;

@interface ZSellModuleImageDescriptionViewController : ZSuperViewController<ZListPostCellDelegate, MFMailComposeViewControllerDelegate>
{
            BOOL _shouldScrollToBottom;
}

@property (nonatomic, retain) ZSellImageModel *imageModel;
@property (nonatomic, retain) NSString *imageModelId;
@property (nonatomic, assign) ImageDescriptionScreenState screenState;

@end
