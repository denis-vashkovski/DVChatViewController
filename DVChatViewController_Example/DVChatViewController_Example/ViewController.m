//
//  ViewController.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "ViewController.h"

#import "DVMessageObject.h"
#import "DVMessageView.h"

#pragma mark -
#pragma mark ViewController
@interface ViewController ()<DVTextViewToolbarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableViewChat;

@property (nonatomic, strong) NSArray<DVMessageObject *> *messages;
@end

@implementation ViewController

- (NSArray<DVMessageObject *> *)messages {
    if (!_messages) {
        _messages = @[ [DVMessageObject messageWithText:@"Test1" userName:@"User1" currentUserOwner:YES],
                       [DVMessageObject messageWithText:@"Test2" userName:@"User2" currentUserOwner:NO],
                       [DVMessageObject messageWithText:@"Test3" userName:@"User1" currentUserOwner:YES],
                       [DVMessageObject messageWithText:@"Test4" userName:@"User2" currentUserOwner:NO],
                       [DVMessageObject messageWithText:@"Test5" userName:@"User1" currentUserOwner:YES],
                       [DVMessageObject messageWithText:@"Test6" userName:@"User2" currentUserOwner:NO],
                       [DVMessageObject messageWithText:@"Test5" userName:@"User1" currentUserOwner:YES],
                       [DVMessageObject messageWithText:@"Test6" userName:@"User2" currentUserOwner:NO] ];
    }
    return _messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableViewChat.dataSource = self;
    self.tableViewChat.delegate = self;
    
    [self.navigationItem setTitle:@"Chat"];
    
    UIButton *buttonSend = [[UIButton alloc] initWithFrame:CGRectMake(.0, .0, 50., 36.)];
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
    
    [self.tableViewChat setBackgroundColor:[UIColor whiteColor]];
    [self.dv_textViewToolbar setDVDelegate:self];
    [self.dv_textViewToolbar setDVTextViewInsets:UIEdgeInsetsMake(4., 4., 4., CGRectGetWidth(buttonSend.frame) + 8.)];
    [self.dv_textViewToolbar.dv_textView setDVPlaceholder:[[NSAttributedString alloc] initWithString:@"New message"
                                                                                          attributes:@{ NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                                                                                        NSFontAttributeName: [UIFont systemFontOfSize:17.] }]];
    [self.dv_textViewToolbar.dv_textView setTextContainerInset:UIEdgeInsetsMake(16., 16., 16., 16.)];
}

#pragma mark DVChatViewControllerDataSource
- (UIView *)dv_messagesViewForChatViewController:(DVChatViewController *)chatViewController {
    return self.tableViewChat;
}

#pragma mark UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DVMessageView viewHeightForMessage:self.messages[indexPath.row]] + 20.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Message Cell ID" forIndexPath:indexPath];
    
    DVMessageView *messageView = (DVMessageView *)[cell viewWithTag:MESSAGE_VIEW_TAG];
    [messageView setMessage:self.messages[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark Actions
- (void)onButtonSendTouch {
    if (!self.dv_textViewToolbar.dv_textView.text || (self.dv_textViewToolbar.dv_textView.text.length == 0)) {
        return;
    }
    
    NSMutableArray *messages = self.messages.mutableCopy;
    [messages addObject:[DVMessageObject messageWithText:self.dv_textViewToolbar.dv_textView.text userName:@"User1" currentUserOwner:YES]];
    self.messages = [NSArray arrayWithArray:messages];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0];
    [self.tableViewChat insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self dv_scrollToBottomChatViewController:self animated:YES];
    [self.dv_textViewToolbar.dv_textView setText:nil];
    
    [self.dv_textViewToolbar.dv_textView resignFirstResponder];
}

@end
