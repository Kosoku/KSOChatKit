//
//  KSOChatDefaultTypingIndicatorView.h
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

#import <UIKit/UIKit.h>
#import <KSOChatKit/KSOChatTypingIndicatorView.h>

NS_ASSUME_NONNULL_BEGIN

/**
 KSOChatDefaultTypingIndicatorView is a UIView subclass that conforms to the KSOChatTypingIndicatorView protocol. It provides a default implementation of a typing indicator view that can be used with KSOChatViewController. The appearance of the view is controlled by its theme, which is an instance of KSOChatTheme.
 */
@interface KSOChatDefaultTypingIndicatorView : UIView <KSOChatTypingIndicatorView>

/**
 Get the ordered set of names being displayed by the receiver.
 */
@property (readonly,copy,nonatomic,nullable) NSOrderedSet<NSString *> *names;

/**
 The duration that each name is displayed before being hidden. If the duration is set to 0.0, the receiver will never hide names or itself automatically.
 
 The default is 5.0.
 */
@property (assign,nonatomic) NSTimeInterval nameDisplayDuration;

/**
 Hide the receiver with optional animation. The user can also hide the view by tapping on it.
 
 @param hidden Whether the receiver should be hidden
 @param animated Whether to animate the change
 */
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

/**
 Add the *name* to the list of names displayed by the receiver. When the first name is added the receiver will show itself.
 
 @param name The name to add
 */
- (void)addName:(NSString *)name;
/**
 Remove the *name* to the list of names displayed by the receiver. When the last name is removed the receiver will hide itself.
 
 @param name The name to remove
 */
- (void)removeName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
