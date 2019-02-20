//
//  KSOChatViewModel.h
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
#import <Agamotto/KAGAction.h>
#import "KSOChatViewControllerDefines.h"
#import "KSOChatViewControllerDelegate.h"
#import "KSOChatCompletionCell.h"
#import "KSOChatTypingIndicatorView.h"

typedef void(^KSOChatViewModelRequestCompletionsBlock)(NSArray<id<KSOChatCompletion>> *completions);

@class KSOChatTheme;
@protocol KSOChatViewModelDataSource,KSOChatViewModelViewDelegate;

@interface KSOChatViewModel : NSObject

@property (readonly,weak,nonatomic) KSOChatViewController *chatViewController;

@property (weak,nonatomic) id<KSOChatViewModelDataSource> dataSource;
@property (weak,nonatomic) id<KSOChatViewControllerDelegate> delegate;
@property (readonly,nonatomic) NSSet<id<KSOChatViewModelViewDelegate>> *viewDelegates;

@property (assign,nonatomic) KSOChatViewControllerOptions options;
@property (assign,nonatomic) KSOChatViewControllerMediaTypes pastableMediaTypes;

@property (readonly,nonatomic) BOOL automaticallyShowHideDoneButton;
@property (readonly,nonatomic) BOOL automaticallyScrollToBottomOnKeyboardWillShow;

@property (readonly,assign,nonatomic,getter=isEditing) BOOL editing;

@property (strong,nonatomic) KSOChatTheme *theme;

@property (assign,nonatomic) BOOL allowsChatInputInteraction;

@property (copy,nonatomic) NSString *text;
@property (copy,nonatomic) NSString *textPlaceholder;
@property (copy,nonatomic) NSAttributedString *attributedTextPlaceholder;

@property (assign,nonatomic) NSRange selectedRange;

@property (copy,nonatomic) NSString *editingTitle;

@property (copy,nonatomic) NSString *doneButtonTitle;
@property (copy,nonatomic) NSString *editingCancelButtonTitle;
@property (copy,nonatomic) NSString *editingDoneButtonTitle;

@property (readonly,copy,nonatomic) NSDictionary<NSRegularExpression *, NSDictionary<NSAttributedStringKey, id> *> *syntaxHighlightingRegularExpressionsToTextAttributes;
@property (copy,nonatomic) NSSet<NSString *> *prefixesForCompletion;
@property (readonly,copy,nonatomic) NSDictionary<NSString *, Class<KSOChatCompletionCell>> *prefixesToCompletionCellClasses;
@property (copy,nonatomic) NSArray<NSDictionary<NSString *, NSString *> *> *markdownSymbolsToTitles;
@property (readonly,copy,nonatomic) NSArray<NSString *> *markdownSymbols;

@property (copy,nonatomic) NSArray<UIView *> *leadingAccessoryViews;

@property (strong,nonatomic) UIView<KSOChatTypingIndicatorView> *typingIndicatorView;

@property (readonly,strong,nonatomic) KAGAction *cancelAction;
@property (readonly,strong,nonatomic) KAGAction *doneAction;

- (instancetype)initWithChatViewController:(KSOChatViewController *)chatViewController;

- (void)addViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate;
- (void)removeViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate;

- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes;
- (void)removeSyntaxHighlightingRegularExpressions;

- (void)setCompletionCellClass:(Class<KSOChatCompletionCell>)completionCellClass forPrefix:(NSString *)prefix;
- (void)removeCompletionCellClassForPrefix:(NSString *)prefix;

- (BOOL)shouldChangeTextInRange:(NSRange)range text:(NSString *)text;
- (BOOL)shouldShowCompletionsForRange:(NSRange)range prefix:(NSString **)outPrefix text:(NSString **)outText range:(NSRangePointer)outRange;
- (void)showCompletionsForPrefix:(NSString *)prefix text:(NSString *)text;
- (void)hideCompletions;

- (void)requestCompletionsWithCompletion:(KSOChatViewModelRequestCompletionsBlock)completion;
- (void)selectCompletion:(id<KSOChatCompletion>)completion;

- (void)applyMarkdownSymbolToSelectedRange:(NSString *)markdownSymbol;

- (void)insertTextAtSelectedRange:(NSString *)text;

- (void)editText:(NSString *)text;
- (void)cancelTextEditing;

@end

@protocol KSOChatViewModelDataSource <NSObject>
@required
- (NSRange)selectedRangeForChatViewModel:(KSOChatViewModel *)chatViewModel;
- (void)chatViewModel:(KSOChatViewModel *)chatViewModel didChangeSelectedRange:(NSRange)selectedRange;
@end

@protocol KSOChatViewModelViewDelegate <NSObject>
@optional
- (void)chatViewModelShowCompletions:(KSOChatViewModel *)chatViewModel;
- (void)chatViewModelHideCompletions:(KSOChatViewModel *)chatViewModel;
@end
