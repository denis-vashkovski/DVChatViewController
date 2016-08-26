//
//  DVTextViewToolbar.h
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 25/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DVTextView : UITextView
@property (nonatomic, copy, setter=setDVPlaceholder:) NSAttributedString *dv_placeholder;
@end

@protocol DVTextViewToolbarDelegate;

@interface DVTextViewToolbar : UIToolbar
- (void)dv_configureInputToolbar;

@property (nonatomic, strong, readonly) DVTextView *dv_textView;
@property (nonatomic, assign, setter=setDVMinHeight:) NSUInteger dv_minHeight;
@property (nonatomic, assign, setter=setDVMaxHeight:) NSUInteger dv_maxHeight;
@property (nonatomic, assign, setter=setDVTextViewInsets:) UIEdgeInsets dv_textViewInsets;
@property (nonatomic, weak, setter=setDVDelegate:) id<DVTextViewToolbarDelegate> dv_delegate;
@end

@protocol DVTextViewToolbarDelegate <NSObject>

@end
