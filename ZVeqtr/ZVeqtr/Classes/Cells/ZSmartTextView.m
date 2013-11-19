//
//  ZSmartTextView.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/25/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSmartTextView.h"

@interface ZSmartTextView ()
@property (nonatomic, retain) NSArray *allComponents;
@end


@implementation ZSmartTextView

//- (void)drawRect:(CGRect)rect
//{
//	if (!self.text) {
//		return;
//	}
//	[[UIColor blackColor] set];
//	[self.text drawAtPoint:CGPointZero withFont:[UIFont systemFontOfSize:14]];
//}

static CGFloat ItemHeight = 25;

+ (void)setItemHeight:(CGFloat)height {
	ItemHeight = height;
}

+ (CGFloat)itemHeight {
	return ItemHeight;
}

+ (CGFloat)heightOfText:(NSString *)text {
	NSArray *arr = [self detectComponentsInText:text];
	return arr.count * ItemHeight;
}

- (void)setSmartText:(NSString *)text {
	if (self.text != text) {
		self.text = text;
		[self reloadItself];
	}
}

+ (NSArray *)detectComponentsInText:(NSString *)text {
	
	NSArray *substrings = [text componentsSeparatedByCharactersInSet:
						   [NSCharacterSet characterSetWithCharactersInString:@", "]];
	if (substrings.count == 0) {
		substrings = @[text];
	}
	
	NSMutableArray *arrResultComponents = [NSMutableArray arrayWithCapacity:substrings.count];
	
	NSError *error = NULL;
	NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber
															   error:&error];
	
	NSMutableString *plainText = nil;
	for (NSString *component in substrings) {
		component = [component trimWhitespace];
		ZSmartTextKind kind = ZSmartTextKindUndefined;
		NSString *formattedString = nil;
		if (component.length == 0) {
			continue;
		}
		if ([component hasPrefix:@"#"]) {
			//	hashtag
			kind = ZSmartTextKindHashtag;
			formattedString = component;
			plainText = nil;
		}
		else {
			NSArray *matches = [detector matchesInString:component
												 options:0
												   range:NSMakeRange(0, [component length])];
			if (matches.count != 0) {
				plainText = nil;
				NSTextCheckingResult *match = matches[0];
				switch ([match resultType]) {
					case NSTextCheckingTypeLink: {
						kind = ZSmartTextKindLink;
						NSURL *url = [match URL];
						formattedString = [url absoluteString];
						
						break;
					}
						
					case NSTextCheckingTypePhoneNumber: {
						kind = ZSmartTextKindPhoneNumber;
						formattedString = [match phoneNumber];
						
						break;
					}
						
					default:
						break;
				}//sw
			}
			else {
				if (plainText) {
					[plainText appendFormat:@" %@", component];
					//	it is already in array, dont add it twice
					continue;
				}
				else {
					plainText = [[component mutableCopy] autorelease];
				}
			}
		}
		
		if (!formattedString) {
			formattedString = component;
		}
		
		if (plainText) {
			component = plainText;
			formattedString = plainText;
		}
		
		NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  @((int)kind),		@"kind",
								  component,		@"originalText",
								  formattedString,	@"formattedText",
								  nil];
		[arrResultComponents addObject:d];
	}
	
	return arrResultComponents;
}


- (void)createSubviews {
	
	CGRect initFrame = CGRectMake(0, 0, self.bounds.size.width, ItemHeight);
	int i = 0;
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:14];
	
	for (NSMutableDictionary *component in self.allComponents) {
		ZSmartTextKind kind =[component[@"kind"] intValue];
		UIView *nextView = nil;
		
		if (kind == ZSmartTextKindUndefined) {
			//	plain text --> present as a label
			UILabel *lab = [[[UILabel alloc] initWithFrame:initFrame] autorelease];
			lab.font = font ? font : [UIFont systemFontOfSize:14];
			lab.textColor = [UIColor blackColor];
			lab.backgroundColor = [UIColor clearColor];
			lab.text = component[@"originalText"];
			[lab sizeToFit];
			CGRect labFrame = lab.frame;
			if (labFrame.size.width > self.bounds.size.width) {
				labFrame.size.width = self.bounds.size.width;
			}
			nextView = lab;
		}
		else {
			//	something active --> present as a button
			BOOL isTag = (kind == ZSmartTextKindHashtag);
			
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = initFrame;
			btn.backgroundColor = [UIColor clearColor];
			[btn setTitle:component[@"originalText"] forState:UIControlStateNormal];
			UIColor *txtColor = isTag ? [UIColor redColor] : [UIColor blueColor];
			[btn setTitleColor:txtColor forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
			btn.titleLabel.font = font ? font : [UIFont boldSystemFontOfSize:14];
			btn.titleLabel.textAlignment = UITextAlignmentLeft;
			[btn addTarget:self action:@selector(actSelComponent:) forControlEvents:UIControlEventTouchUpInside];
			[btn sizeToFit];
			CGRect btnFrame = btn.frame;
			btnFrame.size.height = ItemHeight;
			btnFrame.size.width = MAX(btnFrame.size.width + 16, 44);
			if (btnFrame.size.width > self.bounds.size.width) {
				btnFrame.size.width = self.bounds.size.width;
			}
			btn.frame = btnFrame;
			
			nextView = btn;
		}
		nextView.tag = i;
		component[@"view"] = nextView;
		
		//	adjust position
		CGRect nextFrame = nextView.frame;
		nextFrame.origin.y = ItemHeight * i;
		nextView.frame = nextFrame;
		[self addSubview:nextView];
		
		if (kind == ZSmartTextKindLink) {
			//	underline if it's a link
			CGRect lineFrame = nextView.frame;
			lineFrame.origin.y = CGRectGetMaxY(lineFrame) - 3;
			lineFrame.size.height = 1;
			lineFrame.size.width -= 16;
			lineFrame.origin.x += 8;
			UIView *underlineView = [[UIView alloc] initWithFrame:lineFrame];
			underlineView.backgroundColor = [UIColor blueColor];
			[self addSubview:underlineView];
			[underlineView release];
		}
		
		++i;
	}
}

- (void)reloadItself {
	//	remove 
	[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	self.allComponents = nil;

	NSString *text = [self.text trimWhitespace];
	if (!text.length) {
		return;
	}

	self.allComponents = [[self class] detectComponentsInText:text];
	
	//	all components are detected, now create them and add as subviews
	[self createSubviews];
}

- (IBAction)actSelComponent:(UIView *)sender {
	
	NSDictionary *component = self.allComponents[sender.tag];

	[self.delegate smartTextView:self
		   didSelectOriginalText:component[@"originalText"]
				   formattedText:component[@"formattedText"]
							kind:(ZSmartTextKind)[component[@"kind"] intValue]];
}

@end
