//
//  DVChatViewController.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVChatViewController.h"

@interface DVChatViewController ()
@property (nonatomic, strong) NSLayoutConstraint *constraintToolbarBottom;
@end

@implementation DVChatViewController

- (UITableView *)dv_tableViewChat:(DVChatViewController *)chatViewController {
    return [UITableView new];
}

- (void)prepareView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _dv_tableViewChat = [self dv_tableViewChat:self];
    [_dv_tableViewChat removeConstraints:_dv_tableViewChat.constraints];
    [_dv_tableViewChat removeFromSuperview];
    [_dv_tableViewChat setDataSource:self];
    [_dv_tableViewChat setDelegate:self];
    [self.view addSubview:_dv_tableViewChat];
    
    _dv_textViewToolbar = [DVTextViewToolbar new];
    [_dv_textViewToolbar dv_configureInputToolbar];
    [self.view addSubview:_dv_textViewToolbar];
    
    [_dv_tableViewChat setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_dv_textViewToolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = @{ @"tableView": _dv_tableViewChat, @"toolbar": _dv_textViewToolbar };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView][toolbar]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    _constraintToolbarBottom = [NSLayoutConstraint constraintWithItem:self.view
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_dv_textViewToolbar
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.f
                                                             constant:.0f];
    [self.view addConstraint:_constraintToolbarBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareView];
    [self dv_scrollToBottomAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(dv_didReceiveKeyboardWillChangeFrameNotification:)
                   name:UIKeyboardWillChangeFrameNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(preferredContentSizeChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(dv_textViewDidBeginEditing:)
                   name:UITextViewTextDidBeginEditingNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(dv_textViewDidChange:)
                   name:UITextViewTextDidChangeNotification
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [center removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
    [center removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
    [center removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dv_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (CGRectIsNull(keyboardEndFrame)) return;
    
    [self.constraintToolbarBottom setConstant:([UIScreen mainScreen].bounds.size.height - CGRectGetMinY(keyboardEndFrame))];
    
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:.0
                        options:([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16)
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self dv_scrollToBottomAnimated:YES];
                     }];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.dv_tableViewChat setNeedsLayout];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - Text view delegate
- (void)dv_textViewDidBeginEditing:(NSNotification *)notification {
    if (notification.object && (notification.object == self.dv_textViewToolbar.dv_textView)) {
        [self dv_scrollToBottomAnimated:YES];
        [self dv_scrollTextViewToBottom:notification.object];
    }
}

- (void)dv_textViewDidChange:(NSNotification *)notification {
    if (notification.object && (notification.object == self.dv_textViewToolbar.dv_textView)) {
        [self dv_scrollToBottomAnimated:YES];
    }
}

#pragma mark - Utils
- (void)dv_scrollToBottomAnimated:(BOOL)animated {
    if (self.dv_tableViewChat.numberOfSections > 0) {
        NSUInteger numberOfRowsInSection = [self.dv_tableViewChat numberOfRowsInSection:0];
        
        if (numberOfRowsInSection > 0) {
            NSIndexPath *lastCell = [NSIndexPath indexPathForItem:(numberOfRowsInSection - 1) inSection:0];
            [self.dv_tableViewChat scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)dv_scrollTextViewToBottom:(UITextView *)textView {
    NSRange range = NSMakeRange(textView.text.length, 0);
    [textView scrollRangeToVisible:range];
    [textView setScrollEnabled:NO];
    [textView setScrollEnabled:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        textView.selectedRange = range;
    });
}

@end
