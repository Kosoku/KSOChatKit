//
//  KSOChatDefaultTypingIndicatorView.m
//  KSOChatKit
//
//  Created by William Towe on 3/11/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOChatDefaultTypingIndicatorView.h"
#import "KSOChatTheme.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Quicksilver/Quicksilver.h>

@interface KSOChatDefaultTypingIndicatorView ()
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UIButton *button;

@property (readwrite,copy,nonatomic) NSOrderedSet<NSString *> *names;

- (void)_updateLabelAttributedText;
@end

@implementation KSOChatDefaultTypingIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    kstWeakify(self);
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.accessibilityLabel = @"Dismiss typing indicator";
    _button.accessibilityHint = @"Tap to dismiss the typing indicator";
    [_button KDI_addBlock:^(__kindof UIControl * _Nonnull control, UIControlEvents controlEvents) {
        kstStrongify(self);
        [self setHidden:YES animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.numberOfLines = 0;
    [self addSubview:_label];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": _label}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": _label}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _button}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _button}]];
    
    return self;
}

@synthesize theme=_theme;
- (void)setTheme:(KSOChatTheme *)theme {
    _theme = theme;
    
    self.backgroundColor = _theme.typingIndicatorBackgroundColor;
    
    [self _updateLabelAttributedText];
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated; {
    void(^block)(void) = ^{
        self.hidden = hidden;
        
        UIView *superview = self.superview;
        
        while (superview != nil) {
            if ([superview isKindOfClass:UIStackView.class]) {
                [superview layoutIfNeeded];
                break;
            }
            superview = superview.superview;
        }
    };
    
    if (animated &&
        self.theme != nil) {
        
        [UIView animateWithDuration:self.theme.animationDuration delay:0 usingSpringWithDamping:self.theme.animationSpringDamping initialSpringVelocity:self.theme.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:block completion:nil];
    }
    else {
        block();
    }
}

- (void)addName:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithOrderedSet:self.names];
    
    [temp addObject:name];
    
    self.names = temp;
}
- (void)removeName:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithOrderedSet:self.names];
    
    [temp removeObject:name];
    
    self.names = temp;
}

- (void)_updateLabelAttributedText; {
    if (self.theme == nil) {
        return;
    }
    
    NSString *text = @"";
    
    if (self.names.count == 1) {
        text = [NSString stringWithFormat:@"%@ is typing",self.names.firstObject];
    }
    else if (self.names.count == 2) {
        text = [NSString stringWithFormat:@"%@ and %@ are typing",self.names.firstObject,self.names.lastObject];
    }
    else if (self.names.count > 2) {
        NSString *namesFormat = [self.names.array KQS_reduceWithStart:[[NSMutableString alloc] init] block:^id _Nonnull(NSMutableString * _Nullable sum, NSString * _Nonnull object, NSInteger index) {
            if (index == self.names.count - 1) {
                [sum appendFormat:@"and %@",object];
            }
            else {
                [sum appendFormat:@"%@, ",object];
            }
            return sum;
        }];
        
        text = [NSString stringWithFormat:@"%@ are typing",namesFormat];
    }
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: self.theme.typingIndicatorFont, NSForegroundColorAttributeName: self.theme.typingIndicatorColor}];
    
    for (NSString *name in self.names) {
        [string addAttributes:@{NSFontAttributeName: self.theme.typingIndicatorNameFont, NSForegroundColorAttributeName: self.theme.typingIndicatorNameColor} range:[string.string rangeOfString:name]];
    }
    
    self.label.attributedText = string;
}

- (void)setNames:(NSOrderedSet<NSString *> *)names {
    _names = [names copy];
    
    [self _updateLabelAttributedText];
    [self setHidden:_names.count == 0 animated:YES];
}

@end
