//
//  KSOChatTheme.m
//  KSOChatKit
//
//  Created by William Towe on 3/5/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOChatTheme.h"

#import <objc/runtime.h>

@interface KSOChatTheme ()
@property (readwrite,copy,nonatomic) NSString *identifier;

+ (UIColor *)_defaultTextColor;
+ (UIFont *)_defaultTextFont;
+ (UIFontTextStyle)_defaultTextStyle;

+ (UIFont *)_defaultButtonFont;
+ (UIFontTextStyle)_defaultButtonTextStyle;
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
    
    retval->_buttonFont = _buttonFont;
    retval->_buttonTextStyle = _buttonTextStyle;
    
    return retval;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (!(self = [super init]))
        return nil;
    
    _identifier = [identifier copy];
    
    _textColor = [self.class _defaultTextColor];
    _textFont = [self.class _defaultTextFont];
    _textStyle = [self.class _defaultTextStyle];
    
    _buttonFont = [self.class _defaultButtonFont];
    _buttonTextStyle = [self.class _defaultButtonTextStyle];
    
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
- (void)setTextStyle:(UIFontTextStyle)textStyle {
    _textStyle = textStyle ?: [self.class _defaultTextStyle];
}

- (void)setButtonFont:(UIFont *)buttonFont {
    _buttonFont = buttonFont ?: [self.class _defaultButtonFont];
}
- (void)setButtonTextStyle:(UIFontTextStyle)buttonTextStyle {
    _buttonTextStyle = buttonTextStyle ?: [self.class _defaultButtonTextStyle];
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
+ (UIFont *)_defaultButtonFont; {
    return [UIFont systemFontOfSize:15.0];
}
+ (UIFontTextStyle)_defaultButtonTextStyle; {
    return UIFontTextStyleCallout;
}

@end
