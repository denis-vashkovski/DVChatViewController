//
//  DVMessageView.h
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DVMessageObject;

#define MESSAGE_VIEW_TAG (1)

@interface DVMessageView : UIView
@property (nonatomic, strong) DVMessageObject *message;
+ (CGFloat)viewHeightForMessage:(DVMessageObject *)message;
@end
