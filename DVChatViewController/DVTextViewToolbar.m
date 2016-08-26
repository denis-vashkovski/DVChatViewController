//
//  DVTextViewToolbar.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVTextViewToolbar.h"

#define MIN_HEIGHT_TOOLBAR_DEFAULT 44.f
#define MAX_HEIGHT_TOOLBAR_DEFAULT 150.f
#define TEXT_VIEW_INSETS_VERTICAL_DEFAULT 4.f
#define TEXT_VIEW_PLACEHOLDER_LEFT_PADDING_DEFAULT 7.

#pragma mark -
#pragma mark DVTextView
@interface DVTextView()
@property (nonatomic, assign, setter=setDVMinHeight:) NSUInteger dv_minHeight;
@property (nonatomic, assign, setter=setDVMaxHeight:) NSUInteger dv_maxHeight;
@end
@implementation DVTextView{
    NSLayoutConstraint *_heightConstraint;
}

- (void)setDVMinHeight:(NSUInteger)dv_minHeight {
    _dv_minHeight = dv_minHeight;
    
    if (_heightConstraint) {
        [self removeConstraint:_heightConstraint];
    }
    
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:0
                                                      constant:_dv_minHeight];
    [self addConstraint:_heightConstraint];
}

#pragma mark Initialization
- (void)dv_configureTextView {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    CGFloat cornerRadius = 6.;
    
    self.backgroundColor = [UIColor whiteColor];
    self.layer.borderWidth = .5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.cornerRadius = cornerRadius;
    
    self.scrollIndicatorInsets = UIEdgeInsetsMake(cornerRadius, .0, cornerRadius, .0);
    
    self.textContainerInset = UIEdgeInsetsMake(4., 2., 4., 2.);
    self.contentInset = UIEdgeInsetsMake(1., .0, 1., .0);
    
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    
    self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.textColor = [UIColor blackColor];
    self.textAlignment = NSTextAlignmentNatural;
    
    self.contentMode = UIViewContentModeRedraw;
    self.dataDetectorTypes = UIDataDetectorTypeNone;
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDefault;
    
    self.text = nil;
    
    self.dv_placeholder = nil;
    
    [self dv_addTextViewNotificationObservers];
}

- (void)dealloc {
    [self dv_removeTextViewNotificationObservers];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize sizeThatFits = [self sizeThatFits:self.frame.size];
    float newHeight = sizeThatFits.height;
    
    if (self.dv_maxHeight) {
        newHeight = MIN(newHeight, self.dv_maxHeight);
    }
    
    if (self.dv_minHeight) {
        newHeight = MAX(newHeight, self.dv_minHeight);
    }
    
    _heightConstraint.constant = newHeight;
}

#pragma mark Setters
- (void)setDVPlaceholder:(NSAttributedString *)dv_placeholder {
    if ([dv_placeholder isEqual:_dv_placeholder]) {
        return;
    }
    
    _dv_placeholder = dv_placeholder;
    [self setNeedsDisplay];
}

#pragma mark UITextView overrides
- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (self.contentSize.height <= (self.bounds.size.height + 1)) {
        self.contentOffset = CGPointZero;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

#pragma mark Drawing
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ((!self.text || (self.text.length == 0)) && self.dv_placeholder && (self.dv_placeholder.length != 0)) {
        [self.dv_placeholder drawInRect:CGRectInset(rect,
                                                    TEXT_VIEW_PLACEHOLDER_LEFT_PADDING_DEFAULT,
                                                    ceilf((CGRectGetHeight(self.frame) - (self.font.capHeight + ABS(self.font.descender) + 7.)) / 2.))];
    }
}

#pragma mark Notifications
- (void)dv_addTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dv_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dv_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dv_didReceiveTextViewNotification:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:self];
}

- (void)dv_removeTextViewNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:self];
}

- (void)dv_didReceiveTextViewNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}
@end

#pragma mark -
#pragma mark DVTextViewToolbar
@interface DVTextViewToolbar()
@property (nonatomic, strong) UIView *dv_contentView;

@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *textViewConstraints;
@end
@implementation DVTextViewToolbar
#pragma mark Initialization
- (void)dv_configureInputToolbar {
    self.backgroundColor = [UIColor whiteColor];
    
    self.dv_contentView = [UIView new];
    [self addSubview:self.dv_contentView];
    
    _dv_textView = [DVTextView new];
    self.dv_minHeight = MIN_HEIGHT_TOOLBAR_DEFAULT;
    self.dv_maxHeight = MAX_HEIGHT_TOOLBAR_DEFAULT;
    [self.dv_contentView addSubview:_dv_textView];
    
    [self.dv_contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dv_textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = @{ @"dv_contentView": self.dv_contentView };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dv_contentView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dv_contentView]|" options:0 metrics:nil views:views]];
    
    [self updateTextViewConstraints];
    
    [self.dv_textView dv_configureTextView];
}

- (void)setDVMinHeight:(NSUInteger)dv_minHeight {
    _dv_minHeight = dv_minHeight;
    
    [_dv_textView setDVMinHeight:(self.dv_minHeight - TEXT_VIEW_INSETS_VERTICAL_DEFAULT * 2)];
}

- (void)setDVMaxHeight:(NSUInteger)dv_maxHeight {
    _dv_maxHeight = dv_maxHeight;
    
    [_dv_textView setDVMaxHeight:(self.dv_maxHeight - TEXT_VIEW_INSETS_VERTICAL_DEFAULT * 2)];
}

- (void)setDVTextViewInsets:(UIEdgeInsets)dv_textViewInsets {
    _dv_textViewInsets = dv_textViewInsets;
    [self updateTextViewConstraints];
}

#pragma mark Utils
- (void)updateTextViewConstraints {
    if (self.textViewConstraints) {
        [self.dv_contentView removeConstraints:self.textViewConstraints];
    }
    
    NSMutableArray *textViewConstraints = [NSMutableArray new];
    NSDictionary *views = @{ @"dv_textView": self.dv_textView };
    [textViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:
                                                                                              @"H:|-%f-[dv_textView]-%f-|",
                                                                                              self.dv_textViewInsets.left,
                                                                                              self.dv_textViewInsets.right]
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];
    [textViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:
                                                                                              @"V:|-%f-[dv_textView]-%f-|",
                                                                                              self.dv_textViewInsets.top,
                                                                                              self.dv_textViewInsets.bottom]
                                                                                     options:0
                                                                                     metrics:nil
                                                                                       views:views]];
    self.textViewConstraints = [NSArray arrayWithArray:textViewConstraints];
    [self.dv_contentView addConstraints:self.textViewConstraints];
}
@end
