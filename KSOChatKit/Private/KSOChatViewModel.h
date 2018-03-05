//
//  KSOChatViewModel.h
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

#import <Foundation/Foundation.h>
#import <Agamotto/KAGAction.h>
#import "KSOChatViewControllerDefines.h"
#import "KSOChatViewControllerDelegate.h"

typedef void(^KSOChatViewModelRequestCompletionsBlock)(NSArray<id<KSOChatCompletion>> *completions);

@protocol KSOChatViewModelDataSource,KSOChatViewModelViewDelegate;

@interface KSOChatViewModel : NSObject

@property (readonly,weak,nonatomic) KSOChatViewController *chatViewController;

@property (weak,nonatomic) id<KSOChatViewModelDataSource> dataSource;
@property (weak,nonatomic) id<KSOChatViewControllerDelegate> delegate;

@property (assign,nonatomic) KSOChatViewControllerOptions options;

@property (copy,nonatomic) NSString *text;

@property (copy,nonatomic) NSSet<NSString *> *prefixesForCompletion;

@property (readonly,strong,nonatomic) KAGAction *doneAction;

- (instancetype)initWithChatViewController:(KSOChatViewController *)chatViewController;

- (void)addViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate;
- (void)removeViewDelegate:(id<KSOChatViewModelViewDelegate>)viewDelegate;

- (BOOL)shouldChangeTextInRange:(NSRange)range text:(NSString *)text;
- (BOOL)shouldShowCompletionsForRange:(NSRange)range prefix:(NSString **)outPrefix text:(NSString **)outText range:(NSRangePointer)outRange;
- (void)showCompletionsForPrefix:(NSString *)prefix text:(NSString *)text;
- (void)hideCompletions;

- (void)requestCompletionsWithCompletion:(KSOChatViewModelRequestCompletionsBlock)completion;
- (void)selectCompletion:(id<KSOChatCompletion>)completion;

@end

@protocol KSOChatViewModelDataSource <NSObject>
@required
- (NSRange)selectedRangeForChatViewModel:(KSOChatViewModel *)chatViewModel;
@end

@protocol KSOChatViewModelViewDelegate <NSObject>
@required
- (void)chatViewModelShowCompletions:(KSOChatViewModel *)chatViewModel;
- (void)chatViewModelHideCompletions:(KSOChatViewModel *)chatViewModel;
@end
