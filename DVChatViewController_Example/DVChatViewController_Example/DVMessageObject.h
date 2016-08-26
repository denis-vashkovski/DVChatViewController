//
//  DVMessageObject.h
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVMessageObject : NSObject
+ (instancetype)messageWithText:(NSString *)text userName:(NSString *)userName currentUserOwner:(BOOL)currentUserOwner;

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) BOOL isCurrentUserOwner;
@end
