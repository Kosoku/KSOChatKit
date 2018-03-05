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
#import "KSOChatViewModel.h"
#import "KSOChatContainerView.h"

#import <Agamotto/Agamotto.h>
#import <Stanley/Stanley.h>
#import <Ditko/Ditko.h>
#import <Quicksilver/Quicksilver.h>

@interface KSOChatViewController ()
@property (strong,nonatomic) KSOChatContainerView *chatContainerView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;

- (void)_addContentViewControllerIfNecessary;
- (void)_adjustContentInsetsIfNecessary;
- (NSArray<NSLayoutConstraint *> *)_chatContainerViewLayoutConstraintsForKeyboardFrame:(CGRect)keyboardFrame;
@end

@implementation KSOChatViewController
#pragma mark *** Subclass Overrides ***
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (!(self = [super initWithNibName:nil bundle:nil]))
        return nil;
    
    _viewModel = [[KSOChatViewModel alloc] initWithChatViewController:self];
    
    return self;
}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatContainerView = [[KSOChatContainerView alloc] initWithViewModel:self.viewModel];
    [self.view addSubview:self.chatContainerView];
    
    self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:CGRectZero];
    
    [self _addContentViewControllerIfNecessary];
    
    kstWeakify(self);
    [self KAG_addObserverForNotificationNames:@[UIKeyboardWillShowNotification,UIKeyboardWillHideNotification] object:nil block:^(NSNotification * _Nonnull notification) {
        kstStrongify(self);
        if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            
            keyboardFrame = [self.view convertRect:[self.view.window convertRect:keyboardFrame fromWindow:nil] fromView:nil];
            
            self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:keyboardFrame];
        }
        else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
            self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:CGRectZero];
        }
        
        [self.view setNeedsLayout];
        [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
            [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
            
            [self.view layoutIfNeeded];
        }];
    }];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self _adjustContentInsetsIfNecessary];
}
#pragma mark *** Public Methods ***
- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes; {
    [self.viewModel addSyntaxHighlightingRegularExpression:regularExpression textAttributes:textAttributes];
}
- (void)removeSyntaxHighlightingRegularExpressions; {
    [self.viewModel removeSyntaxHighlightingRegularExpressions];
}
#pragma mark Properties
@dynamic delegate;
- (id<KSOChatViewControllerDelegate>)delegate {
    return self.viewModel.delegate;
}
- (void)setDelegate:(id<KSOChatViewControllerDelegate>)delegate {
    self.viewModel.delegate = delegate;
}
@dynamic options;
- (KSOChatViewControllerOptions)options {
    return self.viewModel.options;
}
- (void)setOptions:(KSOChatViewControllerOptions)options {
    self.viewModel.options = options;
}
@dynamic theme;
- (KSOChatTheme *)theme {
    return self.viewModel.theme;
}
- (void)setTheme:(KSOChatTheme *)theme {
    self.viewModel.theme = theme;
}
- (void)setContentViewController:(__kindof UIViewController *)contentViewController {
    UIViewController *oldViewController = _contentViewController;
    
    _contentViewController = contentViewController;
    
    if (self.isViewLoaded) {
        [oldViewController willMoveToParentViewController:nil];
        [self _addContentViewControllerIfNecessary];
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
    }
}
@dynamic text;
- (NSString *)text {
    return self.viewModel.text;
}
- (void)setText:(NSString *)text {
    self.viewModel.text = text;
}
@dynamic prefixesForCompletion;
- (NSSet<NSString *> *)prefixesForCompletion {
    return self.viewModel.prefixesForCompletion;
}
- (void)setPrefixesForCompletion:(NSSet<NSString *> *)prefixesForCompletion {
    self.viewModel.prefixesForCompletion = prefixesForCompletion;
}
#pragma mark *** Private Methods ***
- (void)_addContentViewControllerIfNecessary; {
    if (self.contentViewController == nil) {
        return;
    }
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.contentViewController.view belowSubview:self.chatContainerView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
    
    [self.contentViewController didMoveToParentViewController:self];
}
- (void)_adjustContentInsetsIfNecessary; {
    UIScrollView *scrollView = [[self.contentViewController.view KDI_recursiveSubviews] KQS_find:^BOOL(__kindof UIView * _Nonnull object, NSInteger index) {
        return [object isKindOfClass:UIScrollView.class];
    }];
    
    if (scrollView == nil) {
        if ([self.contentViewController.view isKindOfClass:UIScrollView.class]) {
            scrollView = (UIScrollView *)self.contentViewController.view;
        }
    }
    
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.chatContainerView.frame), 0);
}
- (NSArray<NSLayoutConstraint *> *)_chatContainerViewLayoutConstraintsForKeyboardFrame:(CGRect)keyboardFrame {
    return [@[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.chatContainerView}],CGRectIsEmpty(keyboardFrame) ? [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": self.chatContainerView, @"bottom": self.bottomLayoutGuide}] : [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-bottom-|" options:0 metrics:@{@"bottom": @(CGRectGetHeight(CGRectIntersection(self.view.bounds, keyboardFrame)))} views:@{@"view": self.chatContainerView}]] KQS_flatten];
}

@end
