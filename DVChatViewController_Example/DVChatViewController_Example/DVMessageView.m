//
//  DVMessageView.m
//  DVChatViewController_Example
//
//  Created by Denis Vashkovski on 26/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVMessageView.h"

#import "DVMessageObject.h"

#define DV_SCREEN_WIDTH [ [ UIScreen mainScreen ] bounds ].size.width

#define MESSAGE_FONT            [UIFont systemFontOfSize:16.]
#define NAME_FONT               [UIFont systemFontOfSize:10.]

#define BUFFER_WHITE_SPACE      (14.)
#define DETAIL_TEXT_LABEL_WIDTH (DV_SCREEN_WIDTH * 220. / 320.)
#define NAME_OFFSET_ADJUST      (4.)

#define BALLOON_INSET_TOP    (30. / 2.)
#define BALLOON_INSET_LEFT   (36. / 2.)
#define BALLOON_INSET_BOTTOM (30. / 2.)
#define BALLOON_INSET_RIGHT  (46. / 2.)

#define BALLOON_INSET_WIDTH (BALLOON_INSET_LEFT + BALLOON_INSET_RIGHT)
#define BALLOON_INSET_HEIGHT (BALLOON_INSET_TOP + BALLOON_INSET_BOTTOM)

#define BALLOON_MIDDLE_WIDTH (30. / 2.)
#define BALLOON_MIDDLE_HEIGHT (6. / 2.)

#define BALLOON_MIN_HEIGHT (BALLOON_INSET_HEIGHT + BALLOON_MIDDLE_HEIGHT)

#define BALLOON_HEIGHT_PADDING (10.)
#define BALLOON_WIDTH_PADDING (30.)

@interface DVMessageView ()
@property (nonatomic, retain) UIImageView *balloonView;
@property (nonatomic, retain) UITextView *messageTextView;
@property (nonatomic, retain) UILabel *nameLabel;

@property (retain, nonatomic) UIImage *balloonImageLeft;
@property (retain, nonatomic) UIImage *balloonImageRight;
@property (assign, nonatomic) UIEdgeInsets balloonInsetsLeft;
@property (assign, nonatomic) UIEdgeInsets balloonInsetsRight;
@end

@implementation DVMessageView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _balloonView = [UIImageView new];
        
        _messageTextView = [UITextView new];
        _messageTextView.font = MESSAGE_FONT;
        [_messageTextView setScrollEnabled:NO];
        [_messageTextView setBackgroundColor:[UIColor clearColor]];
        [_messageTextView.textContainer setLineFragmentPadding:0.];
        [_messageTextView setTextContainerInset:UIEdgeInsetsZero];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = NAME_FONT;
        _nameLabel.textColor = [UIColor blackColor];
        
        self.balloonImageLeft = [UIImage imageNamed:@"bubble-left"];
        self.balloonImageRight = [UIImage imageNamed:@"bubble-right"];
        
        _balloonInsetsLeft = UIEdgeInsetsMake(BALLOON_INSET_TOP, BALLOON_INSET_RIGHT, BALLOON_INSET_BOTTOM, BALLOON_INSET_LEFT);
        _balloonInsetsRight = UIEdgeInsetsMake(BALLOON_INSET_TOP, BALLOON_INSET_LEFT, BALLOON_INSET_BOTTOM, BALLOON_INSET_RIGHT);
        
        [self addSubview:_balloonView];
        [self addSubview:_messageTextView];
        [self addSubview:_nameLabel];
    }
    return self;
}

- (void)setMessage:(DVMessageObject *)message {
    _message = message;
    
    NSString *nameText = _message.userName;
    _nameLabel.text = nameText;
    
    NSString *messageText = _message.text;
    _messageTextView.text = messageText;
    
    CGSize labelSize = [DVMessageView labelSizeForString:messageText font:MESSAGE_FONT];
    labelSize.height += 5.;
    
    CGSize balloonSize = [DVMessageView balloonSizeForLabelSize:labelSize];
    CGSize nameSize = [DVMessageView labelSizeForString:nameText font:NAME_FONT];
    
    CGFloat xOffsetLabel = (BALLOON_WIDTH_PADDING / 2.) + 3.;
    CGFloat xOffsetNameLabel = xOffsetLabel;
    CGFloat xOffsetBalloon = .0;
    CGFloat yOffset = BUFFER_WHITE_SPACE / 2. + nameSize.height - NAME_OFFSET_ADJUST;
    
    if ([self isSend]) {
        xOffsetNameLabel = DV_SCREEN_WIDTH - MAX(labelSize.width, nameSize.width) - xOffsetNameLabel;
        xOffsetLabel = DV_SCREEN_WIDTH - labelSize.width - xOffsetLabel;
        xOffsetBalloon = DV_SCREEN_WIDTH - balloonSize.width;
        
        _messageTextView.textColor = [UIColor whiteColor];
        _balloonView.image = [self.balloonImageRight resizableImageWithCapInsets:_balloonInsetsRight];
        [_nameLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        _messageTextView.textColor = [UIColor blackColor];
        _balloonView.image = [self.balloonImageLeft resizableImageWithCapInsets:_balloonInsetsLeft];
        [_nameLabel setTextAlignment:NSTextAlignmentLeft];
    }
    
    _messageTextView.frame = CGRectMake(xOffsetLabel, yOffset + 5., labelSize.width, labelSize.height);
    _balloonView.frame = CGRectMake(xOffsetBalloon, yOffset, balloonSize.width, balloonSize.height);
    _nameLabel.frame = CGRectMake(xOffsetNameLabel, 0., nameSize.width, nameSize.height);
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    return [[UIApplication sharedApplication] canOpenURL:URL] && [[UIApplication sharedApplication] openURL:URL];
}

#pragma - Utils
+ (CGFloat)viewHeightForMessage:(DVMessageObject *)message {
    CGFloat labelHeight = [DVMessageView balloonSizeForLabelSize:[DVMessageView labelSizeForString:message.text font:MESSAGE_FONT]].height;
    if ([self isSendMessage:message]) {
        CGFloat nameHeight = [DVMessageView labelSizeForString:message.userName font:NAME_FONT].height;
        return (labelHeight + nameHeight + BUFFER_WHITE_SPACE - NAME_OFFSET_ADJUST);
    } else {
        return (labelHeight + BUFFER_WHITE_SPACE);
    }
}

+ (CGSize)labelSizeForString:(NSString *)string font:(UIFont *)font {
    return CGSizeMake(DETAIL_TEXT_LABEL_WIDTH, [string boundingRectWithSize:CGSizeMake(DETAIL_TEXT_LABEL_WIDTH, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName: font }
                                                                    context:nil].size.height);
}

+ (CGSize)balloonSizeForLabelSize:(CGSize)labelSize {
    CGSize balloonSize;
    balloonSize.height = (labelSize.height < BALLOON_INSET_HEIGHT) ? BALLOON_MIN_HEIGHT : (labelSize.height + BALLOON_HEIGHT_PADDING);
    balloonSize.width = labelSize.width + BALLOON_WIDTH_PADDING;
    
    return balloonSize;
}

+ (BOOL)isSendMessage:(DVMessageObject *)message {
    return message.isCurrentUserOwner;
}

- (BOOL)isSend {
    return [DVMessageView isSendMessage:_message];
}

@end
