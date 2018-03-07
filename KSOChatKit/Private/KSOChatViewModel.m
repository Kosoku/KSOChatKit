//
//  KSOChatViewModel.m
//  KSOChatKit
//
//  Created by William Towe on 3/4/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOChatViewModel.h"
#import "KSOChatViewController.h"
#import "KSOChatTheme.h"

#import <Agamotto/Agamotto.h>
#import <Stanley/Stanley.h>
#import <Quicksilver/Quicksilver.h>

@interface KSOChatViewModel ()
@property (readwrite,weak,nonatomic) KSOChatViewController *chatViewController;
@property (readwrite,assign,nonatomic,getter=isEditing) BOOL editing;
@property (readwrite,copy,nonatomic) NSDictionary<NSRegularExpression *, NSDictionary<NSAttributedStringKey, id> *> *syntaxHighlightingRegularExpressionsToTextAttributes;
@property (readwrite,copy,nonatomic) NSDictionary<NSString *, Class<KSOChatCompletionCell>> *prefixesToCompletionCellClasses;
@property (readwrite,strong,nonatomic) KAGAction *cancelAction;
@property (readwrite,strong,nonatomic) KAGAction *doneAction;

@property (strong,nonatomic) NSHashTable<id<KSOChatViewModelViewDelegate>> *viewDelegatesHashTable;
@property (copy,nonatomic) NSString *textBeforeEditing;

+ (NSString *)_defaultTextPlaceholder;
+ (NSString *)_defaultEditingTitle;
+ (NSString *)_defaultDoneButtonTitle;
+ (NSString *)_defaultEditingCancelButtonTitle;
+ (NSString *)_defaultEditingDoneButtonTitle;
@end

@implementation KSOChatViewModel
#pragma mark *** Subclass Overrides ***
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@kstKeypath(KSOChatViewModel.new,automaticallyShowHideDoneButton)]) {
        return [NSSet setWithObject:@kstKeypath(KSOChatViewModel.new,options)];
    }
    return [super keyPathsForValuesAffectingValueForKey:key];
}
#pragma mark *** Public Methods ***
- (instancetype)initWithChatViewController:(KSOChatViewController *)chatViewController; {
    if (!(self = [super init]))
        return nil;
    
    kstWeakify(self);
    
    _chatViewController = chatViewController;
    _viewDelegatesHashTable = [NSHashTable weakObjectsHashTable];
    
    _options = KSOChatViewControllerOptionsAll;
    _pastableMediaTypes = KSOChatViewControllerMediaTypesAll;
    
    _theme = KSOChatTheme.defaultTheme;
    
    _textPlaceholder = [self.class _defaultTextPlaceholder];
    _editingTitle = [self.class _defaultEditingTitle];
    _doneButtonTitle = [self.class _defaultDoneButtonTitle];
    _editingCancelButtonTitle = [self.class _defaultEditingCancelButtonTitle];
    _editingDoneButtonTitle = [self.class _defaultEditingDoneButtonTitle];
    
    _cancelAction = [[KAGAction alloc] initWithAsynchronousValueErrorBlock:^(KAGValueErrorBlock  _Nonnull completion) {
        kstStrongify(self);
        self.editing = NO;
        self.text = self.textBeforeEditing;
        self.textBeforeEditing = nil;
        
        completion(@NO,nil);
    }];
    _doneAction = [[KAGAction alloc] initWithAsynchronousValueErrorBlock:^(KAGValueErrorBlock  _Nonnull completion) {
        kstStrongify(self);
        if ([self.delegate respondsToSelector:@selector(chatViewControllerDidTapDoneButton:completion:)]) {
            [self.delegate chatViewControllerDidTapDoneButton:self.chatViewController completion:^(BOOL success) {
                kstStrongify(self);
                completion(@(success),nil);
                
                if (success) {
                    if (self.isEditing) {
                        self.editing = NO;
                        self.text = self.textBeforeEditing;
                        self.textBeforeEditing = nil;
                    }
                    else {
                        self.text = nil;
                    }
                }
            }];
        }
        else {
            completion(@NO,nil);
        }
    }];
    
    [self KAG_addObserverForKeyPaths:@[@kstKeypath(self,text)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        if ([keyPath isEqualToString:@kstKeypath(self,text)]) {
            self.doneAction.enabled = self.text.length > 0;
        }
    }];
    
    return self;
}
#pragma mark -
- (void)addViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate; {
    [self.viewDelegatesHashTable addObject:viewDelegate];
}
- (void)removeViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate; {
    [self.viewDelegatesHashTable removeObject:viewDelegate];
}
#pragma mark -
- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes; {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.syntaxHighlightingRegularExpressionsToTextAttributes];
    
    temp[regularExpression] = textAttributes;
    
    self.syntaxHighlightingRegularExpressionsToTextAttributes = temp;
}
- (void)removeSyntaxHighlightingRegularExpressions; {
    self.syntaxHighlightingRegularExpressionsToTextAttributes = nil;
}
#pragma mark -
- (void)setCompletionCellClass:(Class<KSOChatCompletionCell>)completionCellClass forPrefix:(NSString *)prefix; {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.prefixesToCompletionCellClasses];
    
    temp[prefix] = completionCellClass;
    
    self.prefixesToCompletionCellClasses = temp;
}
- (void)removeCompletionCellClassForPrefix:(NSString *)prefix; {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.prefixesToCompletionCellClasses];
    
    [temp removeObjectForKey:prefix];
    
    self.prefixesToCompletionCellClasses = temp;
}
#pragma mark -
- (BOOL)shouldChangeTextInRange:(NSRange)range text:(NSString *)text; {
    if ([text rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet].length > 0 &&
        text.length == 1 &&
        [self.delegate respondsToSelector:@selector(chatViewControllerReturnShouldTapDoneButton:)]) {
        
        if ([self.delegate chatViewControllerReturnShouldTapDoneButton:self.chatViewController]) {
            [self.doneAction execute];
            return NO;
        }
    }
    else if (self.markdownSymbolsToTitles.count > 0 &&
             range.location > 0 &&
             text.length > 0 &&
             [NSCharacterSet.whitespaceCharacterSet characterIsMember:[text characterAtIndex:0]] &&
             self.text.length > range.location - 1 &&
             [NSCharacterSet.whitespaceCharacterSet characterIsMember:[self.text characterAtIndex:range.location - 1]]) {
        
        if ([self.text substringToIndex:self.selectedRange.location].length < 2) {
            return YES;
        }
        
        NSRange wordRange = range;
        
        wordRange.location -= 2;
        
        if (wordRange.location == NSNotFound) {
            return YES;
        }
        
        NSMutableCharacterSet *invalidCharacterSet = [NSCharacterSet.whitespaceAndNewlineCharacterSet mutableCopy];
        
        [invalidCharacterSet formUnionWithCharacterSet:NSCharacterSet.punctuationCharacterSet];
        [invalidCharacterSet removeCharactersInString:[self.markdownSymbols componentsJoinedByString:@""]];
        
        BOOL shouldChange = YES;
        
        for (NSString *symbol in self.markdownSymbols) {
            NSRange searchRange = NSMakeRange(0, wordRange.location);
            NSRange prefixRange = [self.text rangeOfString:symbol options:NSBackwardsSearch range:searchRange];
            
            if (prefixRange.length == 0) {
                continue;
            }
            
            NSRange nextCharRange = NSMakeRange(prefixRange.location + 1, 1);
            NSString *charAfterSymbol = [self.text substringWithRange:nextCharRange];
            
            if ([invalidCharacterSet characterIsMember:[charAfterSymbol characterAtIndex:0]]) {
                continue;
            }
            
            if ([self.delegate respondsToSelector:@selector(chatViewController:shouldInsertSuffixForMarkdownSymbol:)] &&
                ![self.delegate chatViewController:self.chatViewController shouldInsertSuffixForMarkdownSymbol:symbol]) {
                
                continue;
            }
            
            NSRange suffixRange;
            [self.text KST_wordAtRange:wordRange outRange:&suffixRange];
            
            // Skip if the detected word already has a suffix
            if ([[self.text substringWithRange:suffixRange] hasSuffix:symbol]) {
                continue;
            }
            
            suffixRange.location += suffixRange.length;
            suffixRange.length = 0;
            
            NSString *lastCharacter = [self.text substringWithRange:NSMakeRange(suffixRange.location, 1)];
            
            // Checks if the last character was a line break, so we append the symbol in the next line too
            if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[lastCharacter characterAtIndex:0]]) {
                suffixRange.location += 1;
            }
            
            self.text = [self.text stringByReplacingCharactersInRange:suffixRange withString:symbol];
            shouldChange = NO;
            
            // Reset the original cursor location +1 for the new character
            NSRange adjustedCursorPosition = NSMakeRange(range.location + 1, 0);
            self.selectedRange = adjustedCursorPosition;
            
            break;
        }
        
        return shouldChange;
    }
    return YES;
}
- (BOOL)shouldShowCompletionsForRange:(NSRange)range prefix:(NSString **)outPrefix text:(NSString **)outText range:(NSRangePointer)outRange; {
    if (self.prefixesForCompletion.count == 0) {
        return NO;
    }
    
    NSString *text = [self.text KST_wordAtRange:range outRange:outRange];
    
    if (text.length == 0) {
        return NO;
    }
    
    for (NSString *prefix in self.prefixesForCompletion) {
        if ([text hasPrefix:prefix]) {
            if (outPrefix != NULL) {
                *outPrefix = prefix;
            }
            if (outText != nil) {
                *outText = [text substringFromIndex:prefix.length];
            }
            
            return YES;
        }
    }
    
    return NO;
}
- (void)showCompletionsForPrefix:(NSString *)prefix text:(NSString *)text; {
    if (self.prefixesForCompletion.count == 0) {
        return;
    }
    
    if (![self.delegate respondsToSelector:@selector(chatViewController:shouldShowCompletionsForPrefix:text:)] ||
        ![self.delegate chatViewController:self.chatViewController shouldShowCompletionsForPrefix:prefix text:text]) {
        
        [self hideCompletions];
        
        return;
    }
    
    for (id<KSOChatViewModelViewDelegate> delegate in self.viewDelegates) {
        if ([delegate respondsToSelector:@selector(chatViewModelShowCompletions:)]) {
            [delegate chatViewModelShowCompletions:self];
        }
    }
}
- (void)hideCompletions; {
    if (self.prefixesForCompletion.count == 0) {
        return;
    }
    
    for (id<KSOChatViewModelViewDelegate> delegate in self.viewDelegates) {
        if ([delegate respondsToSelector:@selector(chatViewModelHideCompletions:)]) {
            [delegate chatViewModelHideCompletions:self];
        }
    }
}
#pragma mark -
- (void)requestCompletionsWithCompletion:(KSOChatViewModelRequestCompletionsBlock)completion {
    if (![self.delegate respondsToSelector:@selector(chatViewController:completionsForPrefix:text:)]) {
        completion(nil);
        return;
    }
    
    NSString *outPrefix;
    NSString *outText;
    NSRange range = [self.dataSource selectedRangeForChatViewModel:self];
    
    if ([self shouldShowCompletionsForRange:range prefix:&outPrefix text:&outText range:NULL]) {
        NSArray *completions = [self.delegate chatViewController:self.chatViewController completionsForPrefix:outPrefix text:outText];
        
        completion(completions);
    }
    else {
        completion(nil);
    }
}
- (void)selectCompletion:(id<KSOChatCompletion>)completion; {
    NSRange outRange;
    NSRange range = [self.dataSource selectedRangeForChatViewModel:self];
    
    if ([self shouldShowCompletionsForRange:range prefix:NULL text:NULL range:&outRange]) {
        if ([self.delegate respondsToSelector:@selector(chatViewController:textForCompletion:)]) {
            NSString *text = [self.delegate chatViewController:self.chatViewController textForCompletion:completion];
            
            self.text = [self.text stringByReplacingCharactersInRange:outRange withString:text];
        }
    }
    
    [self hideCompletions];
}
#pragma mark -
- (void)applyMarkdownSymbolToSelectedRange:(NSString *)markdownSymbol; {
    NSRange range = self.selectedRange;
    
    if (range.length == 0) {
        return;
    }
    
    NSString *substring = [self.text substringWithRange:range];
    NSString *insertString = [NSString stringWithFormat:@"%@%@",markdownSymbol,substring];
    
    if (![self.delegate respondsToSelector:@selector(chatViewController:shouldInsertSuffixForMarkdownSymbol:)] ||
        [self.delegate chatViewController:self.chatViewController shouldInsertSuffixForMarkdownSymbol:markdownSymbol]) {
        
        insertString = [insertString stringByAppendingString:markdownSymbol];
    }
    
    self.text = [self.text stringByReplacingCharactersInRange:range withString:insertString];
    
    self.selectedRange = NSMakeRange(range.location + insertString.length, 0);
}
#pragma mark -
- (void)insertTextAtSelectedRange:(NSString *)text; {
    NSRange range = self.selectedRange;
    
    self.text = [self.text stringByReplacingCharactersInRange:range withString:text];
    
    if (range.length > 0) {
        self.selectedRange = NSMakeRange(range.location, text.length);
    }
    else {
        self.selectedRange = NSMakeRange(range.location + text.length, 0);
    }
}
#pragma mark -
- (void)editText:(NSString *)text; {
    self.textBeforeEditing = self.text;
    self.text = text;
    self.editing = YES;
}
- (void)cancelTextEditing; {
    [self.cancelAction execute];
}
#pragma mark Properties
- (NSSet<id<KSOChatViewModelViewDelegate>> *)viewDelegates {
    return self.viewDelegatesHashTable.setRepresentation;
}
- (BOOL)automaticallyShowHideDoneButton {
    return self.options & KSOChatViewControllerOptionsAutomaticallyShowHideDoneButton;
}
- (BOOL)automaticallyScrollToBottomOnKeyboardWillShow {
    return self.options & KSOChatViewControllerOptionsAutomaticallyScrollToBottomOnKeyboardWillShow;
}
- (void)setTheme:(KSOChatTheme *)theme {
    _theme = theme ?: KSOChatTheme.defaultTheme;
}
- (void)setTextPlaceholder:(NSString *)textPlaceholder {
    _textPlaceholder = textPlaceholder ?: [self.class _defaultTextPlaceholder];
}
@dynamic selectedRange;
- (NSRange)selectedRange {
    return [self.dataSource selectedRangeForChatViewModel:self];
}
- (void)setSelectedRange:(NSRange)selectedRange {
    [self.dataSource chatViewModel:self didChangeSelectedRange:selectedRange];
}

- (void)setEditingTitle:(NSString *)editingTitle {
    _editingTitle = editingTitle ?: [self.class _defaultEditingTitle];
}

- (void)setDoneButtonTitle:(NSString *)doneButtonTitle {
    _doneButtonTitle = doneButtonTitle ?: [self.class _defaultDoneButtonTitle];
}
- (void)setEditingCancelButtonTitle:(NSString *)editingCancelButtonTitle {
    _editingCancelButtonTitle = editingCancelButtonTitle ?: [self.class _defaultEditingCancelButtonTitle];
}
- (void)setEditingDoneButtonTitle:(NSString *)editingDoneButtonTitle {
    _editingDoneButtonTitle = editingDoneButtonTitle ?: [self.class _defaultEditingDoneButtonTitle];
}
- (NSArray<NSString *> *)markdownSymbols {
    return [self.markdownSymbolsToTitles KQS_map:^id _Nullable(NSDictionary<NSString *,NSString *> * _Nonnull object, NSInteger index) {
        return object.allKeys.firstObject;
    }];
}
#pragma mark *** Private Methods ***
+ (NSString *)_defaultTextPlaceholder; {
    return @"Enter Message…";
}
+ (NSString *)_defaultEditingTitle; {
    return @"Editing";
}
+ (NSString *)_defaultDoneButtonTitle; {
    return @"Send";
}
+ (NSString *)_defaultEditingCancelButtonTitle; {
    return @"Cancel";
}
+ (NSString *)_defaultEditingDoneButtonTitle; {
    return @"Save";
}

@end
