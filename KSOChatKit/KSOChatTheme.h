//
//  KSOChatTheme.h
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
 The text color for the text placeholder that is visible when there is no text in the text view.
 
 The default is UIColor.lightGrayColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *textPlaceholderColor;

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
 The color used for the top border of the text input view and the completions table view.
 
 The default is KDIColorW(0.85).
 */
@property (strong,nonatomic,null_resettable) UIColor *containerBorderColor;

/**
 The background color for the typing indicator view.
 
 The default is KDIColorW(0.95).
 */
@property (strong,nonatomic,null_resettable) UIColor *typingIndicatorBackgroundColor;
/**
 The text color for the typing indicator view.
 
 The default is UIColor.grayColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *typingIndicatorColor;
/**
 The text color for names displayed by the typing indicator view.
 
 The default is UIColor.darkGrayColor.
 */
@property (strong,nonatomic,null_resettable) UIColor *typingIndicatorNameColor;
/**
 The font used for the typing indicator view.
 
 The default is [UIFont systemFontOfSize:13.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *typingIndicatorFont;
/**
 The font used for names displayed by the typing indicator view.
 
 The default is [UIFont boldSystemFontOfSize:13.0].
 */
@property (strong,nonatomic,null_resettable) UIFont *typingIndicatorNameFont;

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
