//
//  KSOChatDefaultTypingIndicatorView.m
//  KSOChatKit
//
//  Created by William Towe on 3/11/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "KSOChatDefaultTypingIndicatorView.h"
#import "KSOChatTheme.h"
#import "NSBundle+KSOChatKitExtensionsPrivate.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Quicksilver/Quicksilver.h>

@interface KSOChatDefaultTypingIndicatorView ()
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UIButton *button;

@property (readwrite,copy,nonatomic) NSOrderedSet<NSString *> *names;

@property (strong,nonatomic) NSMutableDictionary<NSString *, KSTTimer *> *namesToTimers;

- (void)_updateLabelAttributedText;
- (void)_addTimerForName:(NSString *)name;
- (void)_removeTimerForName:(NSString *)name;
- (void)_removeAllTimers;
@end

@implementation KSOChatDefaultTypingIndicatorView

- (void)dealloc {
    for (KSTTimer *timer in _namesToTimers.allValues) {
        [timer invalidate];
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    
    kstWeakify(self);
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _nameDisplayDuration = 5.0;
    
    _namesToTimers = [[NSMutableDictionary alloc] init];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.translatesAutoresizingMaskIntoConstraints = NO;
    _button.accessibilityLabel = NSLocalizedStringWithDefaultValue(@"typing-indicator.dismiss.accessibility-label", nil, NSBundle.KSO_chatKitFrameworkBundle, @"Dismiss typing indicator", @"Dismiss typing indicator");
    _button.accessibilityHint = NSLocalizedStringWithDefaultValue(@"typing-indicator.dismiss.accessibility-hint", nil, NSBundle.KSO_chatKitFrameworkBundle, @"Double tap to dismiss the typing indicator", @"Tap to dismiss the typing indicator");
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
    if (hidden) {
        [self _removeAllTimers];
    }
    
    void(^block)(void) = ^{
        self.hidden = hidden;
        self.alpha = hidden ? 0.0 : 1.0;
        
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
    
    [self _addTimerForName:name];
    
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithOrderedSet:self.names];
    
    [temp addObject:name];
    
    self.names = temp;
}
- (void)removeName:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    [self _removeTimerForName:name];
    
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
        text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"typing-indicator.text.one", nil, NSBundle.KSO_chatKitFrameworkBundle, @"%@ is typing", @"<name> is typing"),self.names.firstObject];
    }
    else if (self.names.count == 2) {
        text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"typing-indicator.text.two", nil, NSBundle.KSO_chatKitFrameworkBundle, @"%@ and %@ are typing", @"<name1> and <name2> are typing"),self.names.firstObject,self.names.lastObject];
    }
    else if (self.names.count > 2) {
        NSString *conjunction = NSLocalizedStringWithDefaultValue(@"typing-indicator.list.conjuction", nil, NSBundle.KSO_chatKitFrameworkBundle, @"and", @"and");
        NSString *separator = NSLocalizedStringWithDefaultValue(@"typing-indicator.list.separator", nil, NSBundle.KSO_chatKitFrameworkBundle, @" ", @"space");
        NSString *delimiter = NSLocalizedStringWithDefaultValue(@"typing-indicator.list.delimiter", nil, NSBundle.KSO_chatKitFrameworkBundle, @",", @"comma");
        
        NSString *namesFormat = [self.names.array KQS_reduceWithStart:[[NSMutableString alloc] init] block:^id _Nonnull(NSMutableString * _Nullable sum, NSString * _Nonnull object, NSInteger index) {
            if (index == self.names.count - 1) {
                [sum appendFormat:@"%@%@%@",conjunction,separator,object];
            }
            else {
                [sum appendFormat:@"%@%@%@",object,delimiter,separator];
            }
            return sum;
        }];
        
        text = [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"typing-indicator.text.other", nil, NSBundle.KSO_chatKitFrameworkBundle, @"%@ are typing", @"<name1>, <name2>, and <name-n> are typing"),namesFormat];
    }
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: self.theme.typingIndicatorFont, NSForegroundColorAttributeName: self.theme.typingIndicatorColor}];
    
    for (NSString *name in self.names) {
        [string addAttributes:@{NSFontAttributeName: self.theme.typingIndicatorNameFont, NSForegroundColorAttributeName: self.theme.typingIndicatorNameColor} range:[string.string rangeOfString:name]];
    }
    
    self.label.attributedText = string;
}
- (void)_addTimerForName:(NSString *)name; {
    if (self.nameDisplayDuration == 0.0) {
        return;
    }
    
    [self _removeTimerForName:name];
    
    kstWeakify(self);
    self.namesToTimers[name] = [KSTTimer scheduledTimerWithTimeInterval:self.nameDisplayDuration block:^(KSTTimer * _Nonnull timer) {
        kstStrongify(self);
        [self removeName:name];
    } userInfo:nil repeats:NO queue:nil];
}
- (void)_removeTimerForName:(NSString *)name; {
    if (self.nameDisplayDuration == 0.0) {
        return;
    }
    
    [self.namesToTimers[name] invalidate];
    [self.namesToTimers removeObjectForKey:name];
}
- (void)_removeAllTimers; {
    for (KSTTimer *timer in self.namesToTimers.allValues) {
        [timer invalidate];
    }
    [self.namesToTimers removeAllObjects];
}

- (void)setNames:(NSOrderedSet<NSString *> *)names {
    _names = [names copy];
    
    [self _updateLabelAttributedText];
    [self setHidden:_names.count == 0 animated:YES];
}

@end
