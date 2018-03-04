//
//  KSOChatViewController.m
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

#import "KSOChatViewController.h"
#import "KSOChatInputView.h"

#import <Agamotto/Agamotto.h>
#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>
#import <Quicksilver/Quicksilver.h>

@interface KSOChatViewController ()
@property (strong,nonatomic) KSOChatInputView *chatInputView;

- (NSArray<NSLayoutConstraint *> *)_chatInputViewLayoutConstraintsForKeyboardFrame:(CGRect)keyboardFrame;
@end

@implementation KSOChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatInputView = [[KSOChatInputView alloc] initWithFrame:CGRectZero];
    self.chatInputView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.chatInputView];
    
    self.KDI_customConstraints = [self _chatInputViewLayoutConstraintsForKeyboardFrame:CGRectZero];
    
    kstWeakify(self);
    [self KAG_addObserverForNotificationNames:@[UIKeyboardWillShowNotification,UIKeyboardWillHideNotification] object:nil block:^(NSNotification * _Nonnull notification) {
        kstStrongify(self);
        if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            
            keyboardFrame = [self.view convertRect:[self.view.window convertRect:keyboardFrame fromWindow:nil] fromView:nil];
            
            self.KDI_customConstraints = [self _chatInputViewLayoutConstraintsForKeyboardFrame:keyboardFrame];
        }
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
            self.KDI_customConstraints = [self _chatInputViewLayoutConstraintsForKeyboardFrame:CGRectZero];
        }
        
        [self.view setNeedsLayout];
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
            
            [self.view layoutIfNeeded];
        }];
    }];
}

- (NSArray<NSLayoutConstraint *> *)_chatInputViewLayoutConstraintsForKeyboardFrame:(CGRect)keyboardFrame {
    return [@[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.chatInputView}],CGRectIsEmpty(keyboardFrame) ? [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": self.chatInputView, @"bottom": self.bottomLayoutGuide}] : [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-bottom-|" options:0 metrics:@{@"bottom": @(CGRectGetHeight(CGRectIntersection(self.view.bounds, keyboardFrame)))} views:@{@"view": self.chatInputView}]] KQS_flatten];
}

@end
