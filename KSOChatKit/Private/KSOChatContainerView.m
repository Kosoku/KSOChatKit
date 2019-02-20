//
//  KSOChatContainerView.m
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

#import "KSOChatContainerView.h"
#import "KSOChatViewModel.h"
#import "KSOChatInputView.h"
#import "KSOChatCompletionsView.h"

#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatContainerView () <KSOChatViewModelViewDelegate>
@property (readwrite,strong,nonatomic) UILayoutGuide *chatTopInputLayoutGuide;

@property (strong,nonatomic) UIStackView *stackView;

@property (readwrite,strong,nonatomic) KSOChatInputView *chatInputView;
@property (strong,nonatomic) KSOChatCompletionsView *chatCompletionsView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;
@end

@implementation KSOChatContainerView

#pragma mark -
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

- (void)showKeyboard; {
    [self.chatInputView showKeyboard];
}
- (void)hideKeyboard; {
    [self.chatInputView hideKeyboard];
}

- (UILayoutGuide *)chatTypingIndicatorTopLayoutGuide {
    return self.chatInputView.chatTypingIndicatorTopLayoutGuide;
}
- (UILayoutGuide *)chatInputTopLayoutGuide {
    return self.chatInputView.chatInputTopLayoutGuide;
}
- (UIView *)chatInputTopView {
    return self.chatInputView;
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
