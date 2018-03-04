//
//  KSOChatInputAccessoryView.m
//  KSOChatKit
//
//  Created by William Towe on 3/3/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOChatInputView.h"
#import "KSOChatViewController.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatInputView () <UITextViewDelegate>
@property (strong,nonatomic) UIVisualEffectView *visualEffectView;
@property (strong,nonatomic) UIStackView *stackView;

@property (strong,nonatomic) KDITextView *textView;
@property (strong,nonatomic) KDIButton *doneButton;

@property (strong,nonatomic) KAGAction *doneAction;

@property (weak,nonatomic) KSOChatViewController *chatViewController;

@end

@implementation KSOChatInputView
#pragma mark *** Subclass Overrides ***
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)updateConstraints {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.visualEffectView}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.visualEffectView}]];
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    
    self.KDI_customConstraints = temp;
    
    [super updateConstraints];
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:NSCharacterSet.newlineCharacterSet].length > 0 &&
        [self.chatViewController.delegate respondsToSelector:@selector(chatViewControllerReturnShouldTapDoneButton:)]) {
        
        if ([self.chatViewController.delegate chatViewControllerReturnShouldTapDoneButton:self.chatViewController]) {
            [self.doneAction execute:self.doneButton];
            return NO;
        }
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    [self willChangeValueForKey:@kstKeypath(self,text)];
    [self didChangeValueForKey:@kstKeypath(self,text)];
}

#pragma mark *** Public Methods ***
- (instancetype)initWithChatViewController:(KSOChatViewController *)chatViewController {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    kstWeakify(self);
    
    _chatViewController = chatViewController;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = UIColor.clearColor;
    
    _doneAction = [[KAGAction alloc] initWithAsynchronousSenderValueErrorBlock:^(id  _Nullable sender, KAGValueErrorBlock  _Nonnull completion) {
        kstStrongify(self);
        if ([self.chatViewController.delegate respondsToSelector:@selector(chatViewControllerDidTapDoneButton:view:completion:)]) {
            [self.chatViewController.delegate chatViewControllerDidTapDoneButton:self.chatViewController view:sender completion:^(BOOL success) {
                if (success) {
                    self.text = nil;
                }
                completion(@(success),nil);
            }];
        }
        else {
            completion(@NO,nil);
        }
    }];
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
    _visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_visualEffectView];
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentTop;
    _stackView.spacing = 8.0;
    [_visualEffectView.contentView addSubview:_stackView];
    
    _textView = [[KDITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    _textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    _textView.delegate = self;
    _textView.placeholder = @"Message";
    _textView.KDI_dynamicTypeTextStyle = UIFontTextStyleBody;
    _textView.KDI_cornerRadius = 5.0;
    [_stackView addArrangedSubview:_textView];
    
    _doneButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.titleLabel.KDI_dynamicTypeTextStyle = UIFontTextStyleCallout;
    _doneButton.KAG_action = _doneAction;
    [_doneButton setTitle:@"Send" forState:UIControlStateNormal];
    [_stackView addArrangedSubview:_doneButton];
    
    [self KAG_addObserverForKeyPaths:@[@kstKeypath(self,text)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        self.doneAction.enabled = self.text.length > 0;
    }];
    
    return self;
}
#pragma mark Properties
@dynamic text;
- (NSString *)text {
    return self.textView.text;
}
- (void)setText:(NSString *)text {
    self.textView.text = text;
}

@end