//
//  KSOChatViewController.h
//  KSOChatKit
//
//  Created by William Towe on 3/3/18.
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
#import <KSOChatKit/KSOChatViewControllerDelegate.h>
#import <KSOChatKit/KSOChatCompletionCell.h>
#import <KSOChatKit/KSOChatTypingIndicatorView.h>

NS_ASSUME_NONNULL_BEGIN

@class KSOChatTheme;

/**
 KSOChatViewController is a UIViewController subclass that manages various input views and content view controller provided by the client that displays the actual chat content.
 */
@interface KSOChatViewController : UIViewController

/**
 Set and get the delegate of the receiver.
 
 @see KSOChatViewControllerDelegate
 */
@property (weak,nonatomic,nullable) id<KSOChatViewControllerDelegate> delegate;

/**
 Set and get the options of the receiver, which affects various behaviors.
 
 The default is KSOChatViewControllerOptionsAll.
 */
@property (assign,nonatomic) KSOChatViewControllerOptions options;
/**
 Set and get the pastable media types that the user is allowed to pasted into the input text view.
 
 The default is KSOChatViewControllerMediaTypesAll.
 */
@property (assign,nonatomic) KSOChatViewControllerMediaTypes pastableMediaTypes;

/**
 Set and get the theme that controls the appearance of subviews managed by the receiver.
 
 The default is KSOChatTheme.defaultTheme.
 */
@property (strong,nonatomic,null_resettable) KSOChatTheme *theme;

/**
 Set and get whether the user can interact with the chat input view. This affects the userInteractionEnabled property on the appropriate subviews.
 
 The default is YES.
 */
@property (assign,nonatomic) BOOL allowsChatInputInteraction;

/**
 Get whether the keyboard is showing.
 */
@property (readonly,nonatomic,getter=isKeyboardShowing) BOOL keyboardShowing;

/**
 Set and get the content view controller of the receiver. This is the view controller from the client that displays the actual chat content.
 */
@property (strong,nonatomic,nullable) __kindof UIViewController *contentViewController;
/**
 Set and get the text displayed by the receiver in the chat text view. This property is not KVO compliant.
 */
@property (copy,nonatomic,nullable) NSString *text;
/**
 Set and get the text placeholder displayed by the chat text view.
 
 The default is @"Enter Message…".
 */
@property (copy,nonatomic,null_resettable) NSString *textPlaceholder;
/**
 Set and get text view's attributed placeholder text. Use this if you want to completely override styling information inherited from KSOChatTheme.
 
 The default is nil.
 */
@property (copy,nonatomic,nullable) NSAttributedString *attributedTextPlaceholder;

/**
 Set and get the editing title displayed by the receiver when in editing mode.
 
 The default is @"Editing";
 */
@property (copy,nonatomic,null_resettable) NSString *editingTitle;

/**
 Set and get the done button title displayed by the receiver.
 
 The default is @"Send".
 */
@property (copy,nonatomic,null_resettable) NSString *doneButtonTitle;
/**
 Set and get the cancel button title displayed in editing mode.
 
 The default is @"Cancel".
 */
@property (copy,nonatomic,null_resettable) NSString *editingCancelButtonTitle;
/**
 Set and get the done button title displayed in editing mode.
 
 The default is @"Save".
 */
@property (copy,nonatomic,null_resettable) NSString *editingDoneButtonTitle;

/**
 Set and get the prefixes that should trigger the display of the completions table view.
 
 The default is nil.
 */
@property (copy,nonatomic,nullable) NSSet<NSString *> *prefixesForCompletion;

/**
 Set and get the array of markdown symbols to titles that are displayed via UIMenuController.
 
 The default is nil.
 */
@property (copy,nonatomic,nullable) NSArray<NSDictionary<NSString *, NSString *> *> *markdownSymbolsToTitles;

/**
 Set and get the array of leading accessory views anchored against the leading edge of the chat input view.
 
 The default is nil.
 */
@property (copy,nonatomic,nullable) NSArray<UIView *> *leadingAccessoryViews;

/**
 Set and get the typing indicator view displayed above the input view.
 
 The default is nil.
 */
@property (strong,nonatomic,nullable) __kindof UIView<KSOChatTypingIndicatorView> *typingIndicatorView;

/**
 Get the layout guide that can be used to anchor views against the top edge of the typing indicator view when visible, otherwise anchors against the chatInputTopLayoutGuide. This will return nil if referenced before the receiver's view has been loaded.
 */
@property (readonly,nonatomic,nullable) UILayoutGuide *chatTypingIndicatorTopLayoutGuide;
/**
 Get the layout guide that can be used to anchor views against the top edge of the input container view. This will return nil if referenced before the receiver's view has been loaded.
 */
@property (readonly,nonatomic,nullable) UILayoutGuide *chatInputTopLayoutGuide;

/**
 Add a regular expression that should be matched against text while the user is typing and add the *textAttributes* to ranges that match. The *textAttributes* should only specify attributes that do not affect layout (e.g. color, underline).
 
 @param regularExpression The regex to match against
 @param textAttributes The text attributes to add
 */
- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes;
/**
 Removes all regular expressions that are matched against text in the chat text view.
 */
- (void)removeSyntaxHighlightingRegularExpressions;

/**
 Set a custom completions table view cell class that should be used to display completions for the provided *prefix*.
 
 @param completionCellClass The completions table view cell class
 @param prefix The completions prefix
 */
- (void)setCompletionCellClass:(Class<KSOChatCompletionCell>)completionCellClass forPrefix:(NSString *)prefix;
/**
 Removes the custom completions table view cell class for the provided *prefix*.
 
 @param prefix The completions prefix for which to remove the custom table view cell class
 */
- (void)removeCompletionCellClassForPrefix:(NSString *)prefix;

/**
 Enter editing mode with the provided text. The currently entered text will be saved and restored upon exiting editing mode.
 
 @param text The text to enter editing mode with
 */
- (void)editText:(NSString *)text;
/**
 Exit editing mode and restore the previously entered text.
 */
- (void)cancelTextEditing;

/**
 Make the chat text view first responder and show the keyboard.
 */
- (void)showKeyboard;
/**
 Resign first responder on the chat text view and hide the keyboard.
 */
- (void)hideKeyboard;

@end

NS_ASSUME_NONNULL_END
