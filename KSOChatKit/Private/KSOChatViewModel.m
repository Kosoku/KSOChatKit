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

@interface KSOChatViewModel ()
@property (readwrite,weak,nonatomic) KSOChatViewController *chatViewController;
@property (readwrite,copy,nonatomic) NSDictionary<NSRegularExpression *, NSDictionary<NSAttributedStringKey, id> *> *regularExpressionsToTextAttributes;
@property (readwrite,strong,nonatomic) KAGAction *doneAction;

@property (strong,nonatomic) NSHashTable<id<KSOChatViewModelViewDelegate>> *viewDelegatesHashTable;

@end

@implementation KSOChatViewModel

- (instancetype)initWithChatViewController:(KSOChatViewController *)chatViewController; {
    if (!(self = [super init]))
        return nil;
    
    kstWeakify(self);
    
    _chatViewController = chatViewController;
    _viewDelegatesHashTable = [NSHashTable weakObjectsHashTable];
    
    _options = KSOChatViewControllerOptionsShowDoneButton;
    
    _theme = KSOChatTheme.defaultTheme;
    
    _doneAction = [[KAGAction alloc] initWithAsynchronousValueErrorBlock:^(KAGValueErrorBlock  _Nonnull completion) {
        kstStrongify(self);
        if ([self.delegate respondsToSelector:@selector(chatViewControllerDidTapDoneButton:completion:)]) {
            [self.delegate chatViewControllerDidTapDoneButton:self.chatViewController completion:^(BOOL success) {
                completion(@(success),nil);
                
                if (success) {
                    self.text = nil;
                }
            }];
        }
        else {
            completion(@NO,nil);
        }
    }];
    
    [self KAG_addObserverForKeyPaths:@[@kstKeypath(self,text)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        self.doneAction.enabled = self.text.length > 0;
    }];
    
    return self;
}

- (void)addViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate; {
    [self.viewDelegatesHashTable addObject:viewDelegate];
}
- (void)removeViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate; {
    [self.viewDelegatesHashTable removeObject:viewDelegate];
}

- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes; {
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.regularExpressionsToTextAttributes];
    
    temp[regularExpression] = textAttributes;
    
    self.regularExpressionsToTextAttributes = temp;
}
- (void)removeSyntaxHighlightingRegularExpressions; {
    self.regularExpressionsToTextAttributes = nil;
}

- (BOOL)shouldChangeTextInRange:(NSRange)range text:(NSString *)text; {
    if ([text rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet].length > 0 &&
        text.length == 1 &&
        [self.delegate respondsToSelector:@selector(chatViewControllerReturnShouldTapDoneButton:)]) {
        
        if ([self.delegate chatViewControllerReturnShouldTapDoneButton:self.chatViewController]) {
            [self.doneAction execute];
            return NO;
        }
    }
    return YES;
}
- (BOOL)shouldShowCompletionsForRange:(NSRange)range prefix:(NSString **)outPrefix text:(NSString **)outText range:(NSRangePointer)outRange; {
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
    if (![self.delegate respondsToSelector:@selector(chatViewController:shouldShowCompletionsForPrefix:text:)] ||
        ![self.delegate chatViewController:self.chatViewController shouldShowCompletionsForPrefix:prefix text:text]) {
        
        [self hideCompletions];
        
        return;
    }
    
    for (id<KSOChatViewModelViewDelegate> delegate in self.viewDelegatesHashTable) {
        [delegate chatViewModelShowCompletions:self];
    }
}
- (void)hideCompletions; {
    for (id<KSOChatViewModelViewDelegate> delegate in self.viewDelegatesHashTable) {
        [delegate chatViewModelHideCompletions:self];
    }
}

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

- (NSSet<id<KSOChatViewModelViewDelegate>> *)viewDelegates {
    return self.viewDelegatesHashTable.setRepresentation;
}
- (void)setTheme:(KSOChatTheme *)theme {
    _theme = theme ?: KSOChatTheme.defaultTheme;
}

@end
