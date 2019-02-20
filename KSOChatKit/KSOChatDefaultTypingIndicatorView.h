//
//  KSOChatDefaultTypingIndicatorView.h
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
