//
//  DVChatViewController.h
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DVTextViewToolbar.h"

@class DVChatViewController;

@protocol DVChatViewControllerDataSource <NSObject>
- (UIView *)dv_chatViewContainer;
- (UIView *)dv_messagesViewForChatViewController:(DVChatViewController *)chatViewController;
@end

@protocol DVChatViewControllerDelegate <NSObject>
- (void)dv_scrollToBottomChatViewController:(DVChatViewController *)chatViewController animated:(BOOL)animated;
@end

@interface DVChatViewController : UIViewController <DVChatViewControllerDataSource, DVChatViewControllerDelegate, UITextViewDelegate>
@property (nonatomic, strong, readonly) DVTextViewToolbar *dv_textViewToolbar;
@end

