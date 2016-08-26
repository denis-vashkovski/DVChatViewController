//
//  DVMessageObject.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVMessageObject.h"

@implementation DVMessageObject

+ (instancetype)messageWithText:(NSString *)text userName:(NSString *)userName currentUserOwner:(BOOL)currentUserOwner {
    DVMessageObject *message = [DVMessageObject new];
    [message setUserName:userName];
    [message setText:text];
    [message setIsCurrentUserOwner:currentUserOwner];
    return message;
}

@end
