//
//  ViewController.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "ViewController.h"

#pragma mark -
#pragma mark DVMessageObject
@interface DVMessageObject : NSObject
+ (instancetype)messageWithText:(NSString *)text currentUserOwner:(BOOL)currentUserOwner;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) BOOL isCurrentUserOwner;
@end
@implementation DVMessageObject
+ (instancetype)messageWithText:(NSString *)text currentUserOwner:(BOOL)currentUserOwner {
    DVMessageObject *message = [DVMessageObject new];
    [message setText:text];
    [message setIsCurrentUserOwner:currentUserOwner];
    return message;
}
@end

#pragma mark -
#pragma mark ViewController
@interface ViewController ()<DVTextViewToolbarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewChat;

@property (nonatomic, strong) NSArray<DVMessageObject *> *messages;
@end

@implementation ViewController

- (NSArray<DVMessageObject *> *)messages {
    if (!_messages) {
        _messages = @[ [DVMessageObject messageWithText:@"Test1" currentUserOwner:YES],
                       [DVMessageObject messageWithText:@"Test2" currentUserOwner:NO],
                       [DVMessageObject messageWithText:@"Test3" currentUserOwner:YES] ];
    }
    return _messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *buttonSend = [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 50., 44.)];
    [buttonSend setTitle:@"Send" forState:UIControlStateNormal];
    [buttonSend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [buttonSend addTarget:self action:@selector(onButtonSendTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.dv_textViewToolbar addSubview:buttonSend];
    
    [buttonSend setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dv_textViewToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[buttonSend(%f)]-4-|", CGRectGetWidth(buttonSend.frame)]
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(buttonSend)]];
    [self.dv_textViewToolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[buttonSend(%f)]-4-|", CGRectGetHeight(buttonSend.frame)]
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:NSDictionaryOfVariableBindings(buttonSend)]];
    
    [self.dv_tableViewChat setBackgroundColor:[UIColor whiteColor]];
    [self.dv_textViewToolbar setDVDelegate:self];
    [self.dv_textViewToolbar setDVTextViewInsets:UIEdgeInsetsMake(4., 4., 4., CGRectGetWidth(buttonSend.frame) + 8.)];
    [self.dv_textViewToolbar.dv_textView setDVPlaceholder:[[NSAttributedString alloc] initWithString:@"New message"
                                                                                          attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                                                                                        NSFontAttributeName: [UIFont systemFontOfSize:17.] }]];
    
}

#pragma mark DVChatViewControllerDataSource
- (UITableView *)dv_tableViewChat:(DVChatViewController *)chatViewController {
    return _tableViewChat;
}

#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    return footerView;
}

#define MESSAGE_TEXT_FONT [UIFont systemFontOfSize:16.]
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self dv_heightString:self.messages[indexPath.row].text
                            font:MESSAGE_TEXT_FONT
                        andWidth:CGRectGetWidth(tableView.frame)] + 20.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DVMessageObject *message = self.messages[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message Cell ID" forIndexPath:indexPath];
    [cell.textLabel setText:message.text];
    [cell.textLabel setFont:MESSAGE_TEXT_FONT];
    [cell.textLabel setTextAlignment:(message.isCurrentUserOwner ? NSTextAlignmentRight: NSTextAlignmentLeft)];
    
    return cell;
}

#pragma mark Actions
- (void)onButtonSendTouch {
    NSMutableArray *messages = self.messages.mutableCopy;
    [messages addObject:[DVMessageObject messageWithText:self.dv_textViewToolbar.dv_textView.text currentUserOwner:YES]];
    self.messages = [NSArray arrayWithArray:messages];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
    [self.dv_tableViewChat insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self dv_scrollToBottomAnimated:YES];
    [self.dv_textViewToolbar.dv_textView setText:nil];
}

#pragma mark Utils
- (CGFloat)dv_heightString:(NSString *)string font:(UIFont *)font andWidth:(CGFloat)width {
    return ((string && (string.length > 0))
            ? [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{ NSFontAttributeName: font }
                                   context:nil].size.height
            : .0);
}

@end
