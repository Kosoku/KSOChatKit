//
//  KSOChatContainerView.m
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

#import "KSOChatContainerView.h"
#import "KSOChatViewModel.h"
#import "KSOChatInputView.h"
#import "KSOChatCompletionsView.h"

@interface KSOChatContainerView () <KSOChatViewModelViewDelegate>
@property (strong,nonatomic) UIStackView *stackView;

@property (strong,nonatomic) KSOChatInputView *chatInputView;
@property (strong,nonatomic) KSOChatCompletionsView *chatCompletionsView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;
@end

@implementation KSOChatContainerView

- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    _viewModel = viewModel;
    [_viewModel addViewDelegate:self];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:_stackView];
    
    _chatInputView = [[KSOChatInputView alloc] initWithViewModel:_viewModel];
    [_stackView addArrangedSubview:_chatInputView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    
    return self;
}

- (void)chatViewModelShowCompletions:(KSOChatViewModel *)chatViewModel {
    if (self.chatCompletionsView == nil) {
        self.chatCompletionsView = [[KSOChatCompletionsView alloc] initWithViewModel:self.viewModel];
        [self.stackView insertArrangedSubview:self.chatCompletionsView atIndex:0];
    }
    self.chatCompletionsView.hidden = NO;
}
- (void)chatViewModelHideCompletions:(KSOChatViewModel *)chatViewModel {
    if (self.chatCompletionsView != nil) {
        [self.chatCompletionsView removeFromSuperview];
        self.chatCompletionsView = nil;
    }
}

@end
