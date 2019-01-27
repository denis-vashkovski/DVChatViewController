//
//  DVChatViewController.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVChatViewController.h"

@interface DVChatViewController ()
@property (nonatomic, strong) UIView *messagesView;
@property (nonatomic, strong) NSLayoutConstraint *constraintToolbarBottom;
@end

@implementation DVChatViewController

- (UIView *)dv_chatViewContainer {
    return self.view;
}

- (UIView *)dv_messagesViewForChatViewController:(DVChatViewController *)chatViewController {
    return [UIScrollView new];
}

#define CONSTRAINT_TOOLBAR_BOTTOM_DEFAULT .0
- (void)prepareView {
    [self.dv_chatViewContainer setBackgroundColor:[UIColor whiteColor]];
    
    self.messagesView = [self dv_messagesViewForChatViewController:self];
    [self.messagesView removeConstraints:self.messagesView.constraints];
    [self.messagesView removeFromSuperview];
    [self.dv_chatViewContainer addSubview:self.messagesView];
    
    _dv_textViewToolbar = [DVTextViewToolbar new];
    [self.dv_textViewToolbar dv_configureInputToolbar];
    [self.dv_chatViewContainer addSubview:self.dv_textViewToolbar];
    
    [self.messagesView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dv_textViewToolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = @{ @"messagesView": self.messagesView, @"toolbar": self.dv_textViewToolbar };
    [self.dv_chatViewContainer addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messagesView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.dv_chatViewContainer addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[toolbar]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.dv_chatViewContainer addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messagesView][toolbar]"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    self.constraintToolbarBottom = [NSLayoutConstraint constraintWithItem:self.dv_chatViewContainer
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.dv_textViewToolbar
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.f
                                                                 constant:CONSTRAINT_TOOLBAR_BOTTOM_DEFAULT];
    [self.dv_chatViewContainer addConstraint:self.constraintToolbarBottom];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareView];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.dv_chatViewContainer layoutIfNeeded];
    
    for (UIView *view in self.dv_textViewToolbar.subviews) {
        if ([NSStringFromClass(view.class) isEqualToString:@"_UIToolbarContentView"]) {
            [view setUserInteractionEnabled:NO];
        }
    }
    
    [self dv_scrollToBottomChatViewController:self animated:NO];
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
    
    CGRect textViewToolbarFrameGlobal = [self.dv_chatViewContainer convertRect:self.dv_textViewToolbar.frame
                                                                        toView:self.view];
    CGFloat toolbarBottomPadding = (CGRectGetMaxY(textViewToolbarFrameGlobal)
                                    - CGRectGetMinY(keyboardEndFrame));
    [self.constraintToolbarBottom setConstant:MAX(CONSTRAINT_TOOLBAR_BOTTOM_DEFAULT,
                                                  toolbarBottomPadding)];
    
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:.0
                        options:([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16)
                     animations:^{
                         [self.dv_chatViewContainer layoutIfNeeded];
                         [self dv_scrollToBottomChatViewController:self animated:NO];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)preferredContentSizeChanged:(NSNotification *)notification {
    [self.messagesView setNeedsLayout];
}

#pragma mark - Text view delegate
- (void)dv_textViewDidBeginEditing:(NSNotification *)notification {
    if (notification.object && (notification.object == self.dv_textViewToolbar.dv_textView)) {
        [self dv_scrollTextViewToBottom:notification.object];
    }
}

- (void)dv_textViewDidChange:(NSNotification *)notification {
    if (notification.object && (notification.object == self.dv_textViewToolbar.dv_textView)) {
        [self dv_scrollToBottomChatViewController:self animated:YES];
    }
}

#pragma mark - Utils
- (void)dv_scrollToBottomChatViewController:(DVChatViewController *)chatViewController animated:(BOOL)animated {
    if ([self.messagesView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.messagesView;
        NSInteger numberOfSections = collectionView.numberOfSections;
        if (numberOfSections == 0) return;
        
        NSUInteger lastSection = numberOfSections - 1;
        NSUInteger numberOfItemsInLastSection = [collectionView numberOfItemsInSection:lastSection];
        
        if (numberOfItemsInLastSection > 0) {
            NSIndexPath *lastItem = [NSIndexPath indexPathForItem:(numberOfItemsInLastSection - 1) inSection:lastSection];
            [collectionView scrollToItemAtIndexPath:lastItem atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        }
    } else if ([self.messagesView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.messagesView;
        NSInteger numberOfSections = tableView.numberOfSections;
        if (tableView.numberOfSections == 0) return;
        
        NSUInteger lastSection = numberOfSections - 1;
        NSUInteger numberOfRowsInLastSection = [tableView numberOfRowsInSection:lastSection];
        
        if (numberOfRowsInLastSection > 0) {
            NSIndexPath *lastCell = [NSIndexPath indexPathForItem:(numberOfRowsInLastSection - 1) inSection:lastSection];
            [tableView scrollToRowAtIndexPath:lastCell atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    } else if ([self.messagesView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.messagesView;
        
        CGFloat bottomOffset = scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom;
        if (bottomOffset >= 0) {
            [scrollView setContentOffset:CGPointMake(0, bottomOffset) animated:YES];
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
