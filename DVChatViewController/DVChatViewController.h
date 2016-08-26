//
//  DVChatViewController.h
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DVTextViewToolbar.h"

@protocol DVChatViewControllerDataSource;
@protocol DVChatViewControllerDelegate;

@interface DVChatViewController : UIViewController<DVChatViewControllerDataSource, DVChatViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong, readonly) UITableView *dv_tableViewChat;
@property (nonatomic, strong, readonly) DVTextViewToolbar *dv_textViewToolbar;

- (void)dv_scrollToBottomAnimated:(BOOL)animated;
@end

@protocol DVChatViewControllerDataSource <NSObject>
- (UITableView *)dv_tableViewChat:(DVChatViewController *)chatViewController;
@end
@protocol DVChatViewControllerDelegate <NSObject>

@end
