//
//  KSOChatTheme.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOChatTheme represents the appearance of various KSOChatKit views.
 */
@interface KSOChatTheme : NSObject <NSCopying>

/**
 Set and get the default chat theme.
 */
@property (class,strong,nonatomic,null_resettable) KSOChatTheme *defaultTheme;

/**
 The identifier of the theme.
 */
@property (readonly,copy,nonatomic) NSString *identifier;

/**
 The text color for text entered by the user.
 
 The default is UIColor.blackColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *textColor;
/**
 The font for text entered by the user.
 
 The default is [UIFont systemFontOfSize:17.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *textFont;
/**
 The text style for text entered by the user. If this is non-nil the text view that handles user input will automatically adjust when the user changes their preferred text size in Accessibility.
 
 The default is UIFontTextStyleBody.
 */
@property (copy,nonatomic,nullable) UIFontTextStyle textStyle;

/**
 The font for buttons.
 
 The default is [UIFont systemFontOfSize:15.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *buttonFont;
/**
 The text style for buttons. If this is non-nil buttons will automatically adjust when the user changes their preferred text size in Accessibility.
 
 The default is UIFontTextStyleCallout.
 */
@property (copy,nonatomic,nullable) UIFontTextStyle buttonTextStyle;

/**
 The background color of the text view that handles user input.
 
 The default is UIColor.whiteColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *textBackgroundColor;
/**
 The corner radius of the text view that handles user input.
 
 The default is 5.0.
 */
@property (assign,nonatomic) CGFloat textCornerRadius;
/**
 The blur visual effect applied to the main user input controls.
 
 The default is [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent].
 */
@property (strong,nonatomic,null_resettable) UIBlurEffect *textBackgroundBlurEffect;

/**
 The default animation duration used throughout the framework.
 
 The default is 0.25.
 */
@property (assign,nonatomic) CGFloat animationDuration;
/**
 The default spring damping for animations.
 
 The default is 0.7.
 */
@property (assign,nonatomic) CGFloat animationSpringDamping;
/**
 The default initial spring velocity for animations.
 
 The default is 0.0.
 */
@property (assign,nonatomic) CGFloat animationInitialSpringVelocity;

/**
 The designated initializer.
 
 @param identifier The identifier of the receiver
 @return The initialized instance
 */
- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
