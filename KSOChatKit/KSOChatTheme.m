//
//  KSOChatTheme.m
//  KSOChatKit
//
//  Created by William Towe on 3/5/18.
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

#import "KSOChatTheme.h"

#import <Ditko/Ditko.h>

#import <objc/runtime.h>

@interface KSOChatTheme ()
@property (readwrite,copy,nonatomic) NSString *identifier;

+ (UIColor *)_defaultTextColor;
+ (UIFont *)_defaultTextFont;
+ (UIFontTextStyle)_defaultTextStyle;

+ (UIColor *)_defaultTextPlaceholderColor;

+ (UIFont *)_defaultButtonFont;
+ (UIFontTextStyle)_defaultButtonTextStyle;

+ (UIColor *)_defaultTextBackgroundColor;
+ (UIBlurEffect *)_defaultTextBackgroundBlurEffect;

+ (UIColor *)_defaultContainerBorderColor;

+ (UIColor *)_defaultTypingIndicatorBackgroundColor;
+ (UIColor *)_defaultTypingIndicatorColor;
+ (UIColor *)_defaultTypingIndicatorNameColor;
+ (UIFont *)_defaultTypingIndicatorFont;
+ (UIFont *)_defaultTypingIndicatorNameFont;
@end

@implementation KSOChatTheme

- (NSUInteger)hash {
    return self.identifier.hash;
}
- (BOOL)isEqual:(id)object {
    return (self == object ||
            ([object isKindOfClass:KSOChatTheme.class] && [self.identifier isEqualToString:[object identifier]]));
}

- (id)copyWithZone:(NSZone *)zone {
    KSOChatTheme *retval = [[KSOChatTheme alloc] initWithIdentifier:[NSString stringWithFormat:@"%@.copy",self.identifier]];
    
    retval->_textColor = _textColor;
    retval->_textFont = _textFont;
    retval->_textStyle = _textStyle;
    
    retval->_textPlaceholderColor = _textPlaceholderColor;
    
    retval->_buttonFont = _buttonFont;
    retval->_buttonTextStyle = _buttonTextStyle;
    
    retval->_textBackgroundColor = _textBackgroundColor;
    retval->_textCornerRadius = _textCornerRadius;
    retval->_textBackgroundBlurEffect = _textBackgroundBlurEffect;
    
    retval->_animationDuration = _animationDuration;
    retval->_animationSpringDamping = _animationSpringDamping;
    retval->_animationInitialSpringVelocity = _animationInitialSpringVelocity;
    
    retval->_containerBorderColor = _containerBorderColor;
    
    retval->_typingIndicatorBackgroundColor = _typingIndicatorBackgroundColor;
    retval->_typingIndicatorColor = _typingIndicatorColor;
    retval->_typingIndicatorNameColor = _typingIndicatorNameColor;
    retval->_typingIndicatorFont = _typingIndicatorFont;
    retval->_typingIndicatorNameFont = _typingIndicatorNameFont;
    
    return retval;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (!(self = [super init]))
        return nil;
    
    _identifier = [identifier copy];
    
    _textColor = [self.class _defaultTextColor];
    _textFont = [self.class _defaultTextFont];
    _textStyle = [self.class _defaultTextStyle];
    
    _textPlaceholderColor = [self.class _defaultTextPlaceholderColor];
    
    _buttonFont = [self.class _defaultButtonFont];
    _buttonTextStyle = [self.class _defaultButtonTextStyle];
    
    _textBackgroundColor = [self.class _defaultTextBackgroundColor];
    _textCornerRadius = 5.0;
    _textBackgroundBlurEffect = [self.class _defaultTextBackgroundBlurEffect];
    
    _containerBorderColor = [self.class _defaultContainerBorderColor];
    
    _typingIndicatorBackgroundColor = [self.class _defaultTypingIndicatorBackgroundColor];
    _typingIndicatorColor = [self.class _defaultTypingIndicatorColor];
    _typingIndicatorNameColor = [self.class _defaultTypingIndicatorNameColor];
    _typingIndicatorFont = [self.class _defaultTypingIndicatorFont];
    _typingIndicatorNameFont = [self.class _defaultTypingIndicatorNameFont];
    
    _animationDuration = 0.25;
    _animationSpringDamping = 0.7;
    
    return self;
}

static void const *kDefaultThemeKey = &kDefaultThemeKey;
+ (KSOChatTheme *)defaultTheme {
    return objc_getAssociatedObject(self, kDefaultThemeKey) ?: [[KSOChatTheme alloc] initWithIdentifier:@"com.kosoku.ksochatkit.theme.default"];
}
+ (void)setDefaultTheme:(KSOChatTheme *)defaultTheme {
    objc_setAssociatedObject(self, kDefaultThemeKey, defaultTheme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor ?: [self.class _defaultTextColor];
}
- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont ?: [self.class _defaultTextFont];
}

- (void)setTextPlaceholderColor:(UIColor *)textPlaceholderColor {
    _textPlaceholderColor = textPlaceholderColor ?: [self.class _defaultTextPlaceholderColor];
}

- (void)setButtonFont:(UIFont *)buttonFont {
    _buttonFont = buttonFont ?: [self.class _defaultButtonFont];
}
- (void)setButtonTextStyle:(UIFontTextStyle)buttonTextStyle {
    _buttonTextStyle = buttonTextStyle ?: [self.class _defaultButtonTextStyle];
}

- (void)setTextBackgroundColor:(UIColor *)textBackgroundColor {
    _textBackgroundColor = textBackgroundColor ?: [self.class _defaultTextBackgroundColor];
}
- (void)setTextBackgroundBlurEffect:(UIBlurEffect *)textBackgroundBlurEffect {
    _textBackgroundBlurEffect = textBackgroundBlurEffect ?: [self.class _defaultTextBackgroundBlurEffect];
}

- (void)setContainerBorderColor:(UIColor *)containerBorderColor {
    _containerBorderColor = containerBorderColor ?: [self.class _defaultContainerBorderColor];
}

- (void)setTypingIndicatorBackgroundColor:(UIColor *)typingIndicatorBackgroundColor {
    _typingIndicatorBackgroundColor = typingIndicatorBackgroundColor ?: [self.class _defaultTypingIndicatorBackgroundColor];
}
- (void)setTypingIndicatorColor:(UIColor *)typingIndicatorColor {
    _typingIndicatorColor = typingIndicatorColor ?: [self.class _defaultTypingIndicatorColor];
}
- (void)setTypingIndicatorNameColor:(UIColor *)typingIndicatorNameColor {
    _typingIndicatorNameColor = typingIndicatorNameColor ?: [self.class _defaultTypingIndicatorNameColor];
}
- (void)setTypingIndicatorFont:(UIFont *)typingIndicatorFont {
    _typingIndicatorFont = typingIndicatorFont ?: [self.class _defaultTypingIndicatorFont];
}
- (void)setTypingIndicatorNameFont:(UIFont *)typingIndicatorNameFont {
    _typingIndicatorNameFont = typingIndicatorNameFont ?: [self.class _defaultTypingIndicatorNameFont];
}

+ (UIColor *)_defaultTextColor; {
    return UIColor.blackColor;
}
+ (UIFont *)_defaultTextFont; {
    return [UIFont systemFontOfSize:17.0];
}
+ (UIFontTextStyle)_defaultTextStyle; {
    return UIFontTextStyleBody;
}
+ (UIColor *)_defaultTextPlaceholderColor; {
    return UIColor.lightGrayColor;
}
+ (UIFont *)_defaultButtonFont; {
    return [UIFont systemFontOfSize:15.0];
}
+ (UIFontTextStyle)_defaultButtonTextStyle; {
    return UIFontTextStyleCallout;
}
+ (UIColor *)_defaultTextBackgroundColor; {
    return UIColor.whiteColor;
}
+ (UIBlurEffect *)_defaultTextBackgroundBlurEffect; {
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
}
+ (UIColor *)_defaultContainerBorderColor {
    return KDIColorW(0.85);
}
+ (UIColor *)_defaultTypingIndicatorBackgroundColor {
    return KDIColorW(0.95);
}
+ (UIColor *)_defaultTypingIndicatorColor; {
    return UIColor.grayColor;
}
+ (UIColor *)_defaultTypingIndicatorNameColor; {
    return UIColor.darkGrayColor;
}
+ (UIFont *)_defaultTypingIndicatorFont; {
    return [UIFont systemFontOfSize:13.0];
}
+ (UIFont *)_defaultTypingIndicatorNameFont; {
    return [UIFont boldSystemFontOfSize:13.0];
}

@end
