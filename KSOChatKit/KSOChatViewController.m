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

#import <MobileCoreServices/MobileCoreServices.h>

NSArray<NSString*>* KSOChatViewControllerUTIsForMediaTypes(KSOChatViewControllerMediaTypes mediaTypes) {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    if (mediaTypes & KSOChatViewControllerMediaTypesPlainText) {
        [retval addObject:(__bridge id)kUTTypeUTF8PlainText];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesPNG) {
        [retval addObject:(__bridge id)kUTTypePNG];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesJPEG) {
        [retval addObject:(__bridge id)kUTTypeJPEG];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesTIFF) {
        [retval addObject:(__bridge id)kUTTypeTIFF];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesGIF) {
        [retval addObject:(__bridge id)kUTTypeGIF];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesMOV) {
        [retval addObject:(__bridge id)kUTTypeQuickTimeMovie];
    }
    if (mediaTypes & KSOChatViewControllerMediaTypesPassbook) {
        [retval addObject:KSOChatViewControllerUTIPassbook];
    }
    
    return [retval copy];
}
KSOChatViewControllerMediaTypes KSOChatViewControllerMediaTypesFromUTIs(NSArray<NSString *> *UTIs) {
    KSOChatViewControllerMediaTypes retval = KSOChatViewControllerMediaTypesNone;
    
    if ([UTIs containsObject:(__bridge id)kUTTypeUTF8PlainText]) {
        retval |= KSOChatViewControllerMediaTypesPlainText;
    }
    if ([UTIs containsObject:(__bridge id)kUTTypePNG]) {
        retval |= KSOChatViewControllerMediaTypesPNG;
    }
    if ([UTIs containsObject:(__bridge id)kUTTypeJPEG]) {
        retval |= KSOChatViewControllerMediaTypesJPEG;
    }
    if ([UTIs containsObject:(__bridge id)kUTTypeTIFF]) {
        retval |= KSOChatViewControllerMediaTypesTIFF;
    }
    if ([UTIs containsObject:(__bridge id)kUTTypeGIF]) {
        retval |= KSOChatViewControllerMediaTypesGIF;
    }
    if ([UTIs containsObject:(__bridge id)kUTTypeQuickTimeMovie]) {
        retval |= KSOChatViewControllerMediaTypesMOV;
    }
    if ([UTIs containsObject:KSOChatViewControllerUTIPassbook]) {
        retval |= KSOChatViewControllerMediaTypesPassbook;
    }
    
    return retval;
}

NSString *const KSOChatViewControllerUTIPassbook = @"com.apple.pkpass";

@interface KSOChatViewController ()
@property (strong,nonatomic) KSOChatContainerView *chatContainerView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;

- (void)_addContentViewControllerIfNecessary;
- (void)_adjustContentInsetsIfNecessaryForKeyboardNotification:(NSNotification *)notification;
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
- (BOOL)isEditing {
    return self.viewModel.isEditing;
}
#pragma mark -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatContainerView = [[KSOChatContainerView alloc] initWithViewModel:self.viewModel];
    self.chatContainerView.userInteractionEnabled = self.allowsChatInputInteraction;
    [self.view addSubview:self.chatContainerView];
    
    self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:CGRectZero];
    
    [self _addContentViewControllerIfNecessary];
    
    kstWeakify(self);
    [self KAG_addObserverForNotificationNames:@[UIKeyboardWillShowNotification,UIKeyboardWillHideNotification,UIKeyboardDidShowNotification,UIKeyboardDidHideNotification] object:nil block:^(NSNotification * _Nonnull notification) {
        kstStrongify(self);
        if (!self.isKeyboardShowing) {
            self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:CGRectZero];
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(chatViewController:keyboardDidChange:)]) {
            [self.delegate chatViewController:self keyboardDidChange:notification];
        }
        
        if ([notification.name isEqualToString:UIKeyboardWillHideNotification] ||
            [notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            
            if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                
                keyboardFrame = [self.view convertRect:[self.view.window convertRect:keyboardFrame fromWindow:nil] fromView:nil];
                
                self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:keyboardFrame];
            }
            else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
                self.KDI_customConstraints = [self _chatContainerViewLayoutConstraintsForKeyboardFrame:CGRectZero];
                
                [self.viewModel hideCompletions];
            }
            
            [self.view setNeedsLayout];
            [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] animations:^{
                kstStrongify(self);
                [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                
                [self.view layoutIfNeeded];
                
                [self _adjustContentInsetsIfNecessaryForKeyboardNotification:notification];
            }];
        }
    }];
}
#pragma mark *** Public Methods ***
- (void)addSyntaxHighlightingRegularExpression:(NSRegularExpression *)regularExpression textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes; {
    [self.viewModel addSyntaxHighlightingRegularExpression:regularExpression textAttributes:textAttributes];
}
- (void)removeSyntaxHighlightingRegularExpressions; {
    [self.viewModel removeSyntaxHighlightingRegularExpressions];
}
#pragma mark -
- (void)setCompletionCellClass:(Class<KSOChatCompletionCell>)completionCellClass forPrefix:(NSString *)prefix; {
    [self.viewModel setCompletionCellClass:completionCellClass forPrefix:prefix];
}
- (void)removeCompletionCellClassForPrefix:(NSString *)prefix; {
    [self.viewModel removeCompletionCellClassForPrefix:prefix];
}
#pragma mark -
- (void)editText:(NSString *)text; {
    [self.viewModel editText:text];
}
- (void)cancelTextEditing; {
    [self.viewModel cancelTextEditing];
}
#pragma mark -
- (void)showKeyboard; {
    [self.chatContainerView showKeyboard];
}
- (void)hideKeyboard; {
    [self.chatContainerView hideKeyboard];
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
@dynamic pastableMediaTypes;
- (KSOChatViewControllerMediaTypes)pastableMediaTypes {
    return self.viewModel.pastableMediaTypes;
}
- (void)setPastableMediaTypes:(KSOChatViewControllerMediaTypes)pastableMediaTypes {
    self.viewModel.pastableMediaTypes = pastableMediaTypes;
}
@dynamic theme;
- (KSOChatTheme *)theme {
    return self.viewModel.theme;
}
- (void)setTheme:(KSOChatTheme *)theme {
    self.viewModel.theme = theme;
}
@dynamic allowsChatInputInteraction;
- (BOOL)allowsChatInputInteraction {
    return self.viewModel.allowsChatInputInteraction;
}
- (void)setAllowsChatInputInteraction:(BOOL)allowsChatInputInteraction {
    self.viewModel.allowsChatInputInteraction = allowsChatInputInteraction;
    
    self.chatContainerView.userInteractionEnabled = allowsChatInputInteraction;
}
- (BOOL)isKeyboardShowing {
    return [[self.chatContainerView KDI_recursiveSubviews] KQS_any:^BOOL(__kindof UIView * _Nonnull object, NSInteger index) {
        return object.isFirstResponder;
    }];
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
@dynamic textPlaceholder;
- (NSString *)textPlaceholder {
    return self.viewModel.textPlaceholder;
}
- (void)setTextPlaceholder:(NSString *)textPlaceholder {
    self.viewModel.textPlaceholder = textPlaceholder;
}
@dynamic attributedTextPlaceholder;
- (NSAttributedString*)attributedTextPlaceholder {
    return self.viewModel.attributedTextPlaceholder;
}
- (void)setAttributedTextPlaceholder:(NSAttributedString *)attributedTextPlaceholder {
    self.viewModel.attributedTextPlaceholder = attributedTextPlaceholder;
}
@dynamic editingTitle;
- (NSString *)editingTitle {
    return self.viewModel.editingTitle;
}
- (void)setEditingTitle:(NSString *)editingTitle {
    self.viewModel.editingTitle = editingTitle;
}
@dynamic doneButtonTitle;
- (NSString *)doneButtonTitle {
    return self.viewModel.doneButtonTitle;
}
- (void)setDoneButtonTitle:(NSString *)doneButtonTitle {
    self.viewModel.doneButtonTitle = doneButtonTitle;
}
@dynamic editingCancelButtonTitle;
- (NSString *)editingCancelButtonTitle {
    return self.viewModel.editingCancelButtonTitle;
}
- (void)setEditingCancelButtonTitle:(NSString *)editingCancelButtonTitle {
    self.viewModel.editingCancelButtonTitle = editingCancelButtonTitle;
}
@dynamic editingDoneButtonTitle;
- (NSString *)editingDoneButtonTitle {
    return self.viewModel.editingDoneButtonTitle;
}
- (void)setEditingDoneButtonTitle:(NSString *)editingDoneButtonTitle {
    self.viewModel.editingDoneButtonTitle = editingDoneButtonTitle;
}
@dynamic prefixesForCompletion;
- (NSSet<NSString *> *)prefixesForCompletion {
    return self.viewModel.prefixesForCompletion;
}
- (void)setPrefixesForCompletion:(NSSet<NSString *> *)prefixesForCompletion {
    self.viewModel.prefixesForCompletion = prefixesForCompletion;
}
@dynamic markdownSymbolsToTitles;
- (NSArray<NSDictionary<NSString *,NSString *> *> *)markdownSymbolsToTitles {
    return self.viewModel.markdownSymbolsToTitles;
}
- (void)setMarkdownSymbolsToTitles:(NSArray<NSDictionary<NSString *,NSString *> *> *)markdownSymbolsToTitles {
    self.viewModel.markdownSymbolsToTitles = markdownSymbolsToTitles;
}
@dynamic leadingAccessoryViews;
- (NSArray<UIView *> *)leadingAccessoryViews {
    return self.viewModel.leadingAccessoryViews;
}
- (void)setLeadingAccessoryViews:(NSArray<UIView *> *)leadingAccessoryViews {
    self.viewModel.leadingAccessoryViews = leadingAccessoryViews;
}
@dynamic typingIndicatorView;
- (UIView *)typingIndicatorView {
    return self.viewModel.typingIndicatorView;
}
- (void)setTypingIndicatorView:(__kindof UIView *)typingIndicatorView {
    self.viewModel.typingIndicatorView = typingIndicatorView;
}
- (UILayoutGuide *)chatTypingIndicatorTopLayoutGuide {
    return self.chatContainerView.chatTypingIndicatorTopLayoutGuide;
}
- (UILayoutGuide *)chatInputTopLayoutGuide {
    return self.chatContainerView.chatInputTopLayoutGuide;
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
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view][bottom]" options:0 metrics:nil views:@{@"view": self.contentViewController.view, @"bottom": self.chatContainerView.chatInputTopView}]];
    
    [self.contentViewController didMoveToParentViewController:self];
}
- (void)_adjustContentInsetsIfNecessaryForKeyboardNotification:(NSNotification *)notification {
    UIScrollView *scrollView = nil;
    
    if ([self.delegate respondsToSelector:@selector(scrollViewForChatViewController:)]) {
        scrollView = [self.delegate scrollViewForChatViewController:self];
    }
    
    if (scrollView == nil) {
        return;
    }
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification] &&
        self.viewModel.automaticallyScrollToBottomOnKeyboardWillShow) {
        
        [scrollView KDI_scrollToBottomAnimated:YES];
    }
}
- (NSArray<NSLayoutConstraint *> *)_chatContainerViewLayoutConstraintsForKeyboardFrame:(CGRect)keyboardFrame {
    return [@[[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.chatContainerView}],CGRectIsEmpty(keyboardFrame) ? [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": self.chatContainerView, @"bottom": self.bottomLayoutGuide}] : [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-bottom-|" options:0 metrics:@{@"bottom": @(CGRectGetHeight(CGRectIntersection(self.view.bounds, keyboardFrame)))} views:@{@"view": self.chatContainerView}]] KQS_flatten];
}

@end
