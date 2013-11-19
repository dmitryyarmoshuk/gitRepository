//
//  ZSmartTextView.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/25/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZSmartTextViewDelegate;

@interface ZSmartTextView : UIView
{}
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) IBOutlet id<ZSmartTextViewDelegate> delegate;
- (void)setSmartText:(NSString *)text;
+ (NSArray *)detectComponentsInText:(NSString *)text;
+ (void)setItemHeight:(CGFloat)height;
+ (CGFloat)itemHeight;
+ (CGFloat)heightOfText:(NSString *)text;
@end


typedef enum {
	ZSmartTextKindUndefined,
	ZSmartTextKindLink,
	ZSmartTextKindHashtag,
	ZSmartTextKindPhoneNumber
} ZSmartTextKind;


@protocol ZSmartTextViewDelegate <NSObject>
@required
- (void)smartTextView:(ZSmartTextView *)smartTextView
didSelectOriginalText:(NSString *)text
		formattedText:(NSString *)text
				 kind:(ZSmartTextKind)kind;
@end