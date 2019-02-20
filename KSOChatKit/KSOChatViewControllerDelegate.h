//
//  KSOChatViewControllerDelegate.h
//  KSOChatKit
//
//  Created by William Towe on 3/4/18.
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
#import <KSOChatKit/KSOChatViewControllerDefines.h>
#import <KSOChatKit/KSOChatCompletion.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Typedef for completion that the delegate invokes when certain actions have completed.
 
 @param success Whether the action was successful
 */
typedef void(^KSOChatViewControllerCompletionBlock)(BOOL success);

@class KSOChatViewController;

@protocol KSOChatViewControllerDelegate <NSObject>
@optional
/**
 Called when the keyboard state changes, passing the relevant keyboard notification to the delegate.
 
 @param chatViewController The chat view controller that sent the message
 @param notification The keyboard notification
 */
- (void)chatViewController:(KSOChatViewController *)chatViewController keyboardDidChange:(NSNotification *)notification;
/**
 Returns the scroll view that should be adjusted by the receiver. The receiver will adjust the content insets and scroll view insets of the receiver if the return value is non-nil.
 
 @param chatViewController The chat view controller that sent the message
 @return The scroll view that should be adjusted
 */
- (nullable UIScrollView *)scrollViewForChatViewController:(KSOChatViewController *)chatViewController;

/**
 Returns YES if the done button (which includes the Save button in editing mode) should be enabled, otherwise NO. You can inspect the current text through the text property on the sender.
 
 @param chatViewController The chat view controller that sent the message
 @return YES if the done button should be enabled, otherwise NO
 */
- (BOOL)chatViewControllerShouldEnableDoneButton:(KSOChatViewController *)chatViewController;
/**
 Return YES if the receiver should treat the return key as if the user had tapped the Done button.
 
 @param chatViewController The chat view controller that sent the message
 @return YES if return should tap the Done button, otherwise NO
 */
- (BOOL)chatViewControllerReturnShouldTapDoneButton:(KSOChatViewController *)chatViewController;
/**
 Called when the user taps the Done button. The delegate should read the text from the chat view controller, process it, and invoke the completion block when finished.
 
 @param chatViewController The chat view controller that sent the message
 @param completion The completion block to invoke when the operation is finished
 */
- (void)chatViewControllerDidTapDoneButton:(KSOChatViewController *)chatViewController completion:(KSOChatViewControllerCompletionBlock)completion;

/**
 Called when the user enters new text into the chat text view.
 
 @param chatViewController The chat view controller that sent the message
 */
- (void)chatViewControllerDidChangeText:(KSOChatViewController *)chatViewController;

/**
 Called when the user pastes media content into the chat text view. The delegate should act upon the media data and mediaType.
 
 @param chatViewController The chat view controller that sent the message
 @param mediaType The media type that was pasted
 @param data The data that was pasted
 */
- (void)chatViewController:(KSOChatViewController *)chatViewController didPasteMediaType:(KSOChatViewControllerMediaTypes)mediaType data:(NSData *)data;

/**
 Return whether the chat view controller should show the completions table view for the provided prefix.
 
 @param chatViewController The chat view controller that sent the message
 @param prefix The prefix for which to show the completions table view
 @param text The text, not including the prefix, for which to show the completions table view
 @return YES if the completions table view should be shows, otherwise NO
 */
- (BOOL)chatViewController:(KSOChatViewController *)chatViewController shouldShowCompletionsForPrefix:(NSString *)prefix text:(NSString *)text;
/**
 Called immediately before the completions table view is shown. The delegate can customize the appearance of the table view.
 
 @param chatViewController The chat view controller that sent the message
 @param tableView The completions table view
 */
- (void)chatViewController:(KSOChatViewController *)chatViewController willShowCompletionsTableView:(UITableView *)tableView;
/**
 Returns the array of completions to display in the completions table view.
 
 @param chatViewController The chat view controller that sent the message
 @param prefix The prefix for which to return completions
 @param text The text, not including the prefix, for which to return completions
 @return The array of completions to display
 */
- (nullable NSArray<id<KSOChatCompletion>> *)chatViewController:(KSOChatViewController *)chatViewController completionsForPrefix:(NSString *)prefix text:(NSString *)text;
/**
 Returns the text to insert for the selected completion object.
 
 @param chatViewController The chat view controller that sent the message
 @param completion The completion object that was selected
 @return The text to insert
 */
- (NSString *)chatViewController:(KSOChatViewController *)chatViewController textForCompletion:(id<KSOChatCompletion>)completion;

/**
 Returns whether to show the UIMenuItem for the provided *markdownSymbol*.
 
 @param chatViewController The chat view controller that sent the message
 @param markdownSymbol The markdown symbol for which to display a menu item
 @return YES if the menu item should be displayed, otherwise NO
 */
- (BOOL)chatViewController:(KSOChatViewController *)chatViewController shouldShowMenuItemForMarkdownSymbol:(NSString *)markdownSymbol;
/**
 Returns YES if the chat view controller should automatically insert a matching suffix for the provided *markdownSymbol*.
 
 @param chatViewController The chat view controller that sent the message
 @param markdownSymbol The markdown symbol for which to insert a matching suffix
 @return YES if the matching suffix should be inserted, otherwise NO
 */
- (BOOL)chatViewController:(KSOChatViewController *)chatViewController shouldInsertSuffixForMarkdownSymbol:(NSString *)markdownSymbol;
@end

NS_ASSUME_NONNULL_END
