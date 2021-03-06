//
//  KSOChatInputAccessoryView.m
//  KSOChatKit
//
//  Created by William Towe on 3/3/18.
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

#import "KSOChatInputView.h"
#import "KSOChatViewModel.h"
#import "KSOChatTheme.h"
#import "KSOChatEditingView.h"
#import "KSOChatTextView.h"
#import "KSOChatTypingIndicatorView.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatInputView () <KSOChatViewModelDataSource,UITextViewDelegate,NSTextStorageDelegate>
@property (readwrite,strong,nonatomic) UILayoutGuide *chatTypingIndicatorTopLayoutGuide;
@property (readwrite,strong,nonatomic) UILayoutGuide *chatInputTopLayoutGuide;

@property (strong,nonatomic) UIStackView *containingStackView;
@property (strong,nonatomic) UIVisualEffectView *visualEffectView;
@property (strong,nonatomic) UIStackView *stackView;
@property (strong,nonatomic) UIStackView *inputStackView;
@property (strong,nonatomic) UIStackView *leadingAccessoryStackView;

@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) KSOChatTextView *textView;
@property (strong,nonatomic) KDIButton *doneButton;
@property (strong,nonatomic) KSOChatEditingView *editingView;
@property (strong,nonatomic) UIView<KSOChatTypingIndicatorView> *typingIndicatorView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;

- (void)_updateDoneButtonHiddenAnimated:(BOOL)animated;
- (void)_updateForEditingAnimated:(BOOL)animated;
- (void)_updateTypingIndicatorViewAnimated:(BOOL)animated;
@end

@implementation KSOChatInputView
#pragma mark *** Subclass Overrides ***
#pragma mark NSTextStorageDelegate
- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
    if (editedMask & NSTextStorageEditedCharacters) {
        NSRange lineRange = [textStorage.string lineRangeForRange:editedRange];
        
        [textStorage addAttribute:NSForegroundColorAttributeName value:self.viewModel.theme.textColor range:lineRange];
        
        [self.viewModel.syntaxHighlightingRegularExpressionsToTextAttributes enumerateKeysAndObjectsUsingBlock:^(NSRegularExpression * _Nonnull key, NSDictionary<NSAttributedStringKey,id> * _Nonnull obj, BOOL * _Nonnull stop) {
            [key enumerateMatchesInString:textStorage.string options:0 range:lineRange usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                [textStorage addAttributes:obj range:result.range];
            }];
        }];
    }
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [self.viewModel shouldChangeTextInRange:range text:text];
}
- (void)textViewDidChange:(UITextView *)textView {
    self.viewModel.text = self.textView.text;
    
    if ([self.viewModel.delegate respondsToSelector:@selector(chatViewControllerDidChangeText:)]) {
        [self.viewModel.delegate chatViewControllerDidChangeText:self.viewModel.chatViewController];
    }
    
    NSString *outPrefix;
    NSString *outText;
    if ([self.viewModel shouldShowCompletionsForRange:self.viewModel.selectedRange prefix:&outPrefix text:&outText range:NULL]) {
        [self.viewModel showCompletionsForPrefix:outPrefix text:outText];
    }
    else {
        [self.viewModel hideCompletions];
    }
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.viewModel.selectedRange.length > 0) {
        [self.viewModel hideCompletions];
    }
    
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.start];
    
    [self.scrollView scrollRectToVisible:rect animated:NO];
}
#pragma mark KSOChatViewModelDataSource
- (NSRange)selectedRangeForChatViewModel:(KSOChatViewModel *)chatViewModel {
    return KDISelectedRangeFromTextInput(self.textView);
}
- (void)chatViewModel:(KSOChatViewModel *)chatViewModel didChangeSelectedRange:(NSRange)selectedRange {
    self.textView.selectedRange = selectedRange;
}

#pragma mark *** Public Methods ***
- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel; {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    kstWeakify(self);
    
    _viewModel = viewModel;
    _viewModel.dataSource = self;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = UIColor.clearColor;
    
    _containingStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _containingStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _containingStackView.axis = UILayoutConstraintAxisVertical;
    _containingStackView.distribution = UIStackViewDistributionEqualSpacing;
    [self addSubview:_containingStackView];
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:_viewModel.theme.textBackgroundBlurEffect];
    _visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [_containingStackView addArrangedSubview:_visualEffectView];
    
    UIView *topBorderView = [[UIView alloc] initWithFrame:CGRectZero];
    
    topBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    topBorderView.backgroundColor = KDIColorW(0.85);
    
    [_visualEffectView.contentView addSubview:topBorderView];
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 8.0;
    [_visualEffectView.contentView addSubview:_stackView];
    
    _inputStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _inputStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _inputStackView.axis = UILayoutConstraintAxisHorizontal;
    _inputStackView.alignment = UIStackViewAlignmentBottom;
    _inputStackView.spacing = 8.0;
    [_stackView addArrangedSubview:_inputStackView];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.backgroundColor = UIColor.clearColor;
    [_inputStackView addArrangedSubview:_scrollView];
    
    _textView = [[KSOChatTextView alloc] initWithViewModel:self.viewModel];
    _textView.delegate = self;
    _textView.textStorage.delegate = self;
    [_scrollView addSubview:_textView];
    
    _doneButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.titleLabel.font = _viewModel.theme.buttonFont;
    if (_viewModel.theme.buttonTextStyle != nil) {
        _doneButton.titleLabel.KDI_dynamicTypeTextStyle = _viewModel.theme.buttonTextStyle;
    }
    _doneButton.KAG_action = _viewModel.doneAction;
    [_doneButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_inputStackView addArrangedSubview:_doneButton];
    
    _editingView = [[KSOChatEditingView alloc] initWithViewModel:_viewModel];
    [_stackView insertArrangedSubview:_editingView atIndex:0];
    
    _chatInputTopLayoutGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:_chatInputTopLayoutGuide];
    
    _chatTypingIndicatorTopLayoutGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:_chatTypingIndicatorTopLayoutGuide];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _containingStackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _containingStackView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": _stackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": _stackView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": topBorderView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(==height)]" options:0 metrics:@{@"height": @1.0} views:@{@"view": topBorderView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _chatInputTopLayoutGuide}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": _chatInputTopLayoutGuide, @"bottom": _visualEffectView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _chatTypingIndicatorTopLayoutGuide}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": _chatTypingIndicatorTopLayoutGuide, @"bottom": _containingStackView}]];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _textView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _textView}]];
    [NSLayoutConstraint activateConstraints:@[[_textView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor], [_scrollView.heightAnchor constraintLessThanOrEqualToConstant:(ceil(_textView.font.lineHeight) * 3) + _textView.textContainerInset.top + _textView.textContainerInset.bottom]]];
    
    NSLayoutConstraint *scrollViewHeight = [_scrollView.heightAnchor constraintEqualToAnchor:_textView.heightAnchor];
    
    scrollViewHeight.priority = UILayoutPriorityDefaultLow;
    
    [NSLayoutConstraint activateConstraints:@[scrollViewHeight]];
    
    [_viewModel KAG_addObserverForKeyPaths:@[@kstKeypath(_viewModel,text),@kstKeypath(_viewModel,doneButtonTitle),@kstKeypath(_viewModel,textPlaceholder),@kstKeypath(_viewModel,attributedTextPlaceholder),@kstKeypath(_viewModel,editing),@kstKeypath(_viewModel,leadingAccessoryViews),@kstKeypath(_viewModel,typingIndicatorView),@kstKeypath(_viewModel,automaticallyShowHideDoneButton),@kstKeypath(_viewModel,doneAction.enabled)] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        BOOL shouldAnimate = change[NSKeyValueChangeOldKey] != nil;
        
        if ([keyPath isEqualToString:@kstKeypath(self.viewModel,text)]) {
            self.textView.text = self.viewModel.text;
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,doneButtonTitle)]) {
            [self.doneButton setTitle:self.viewModel.doneButtonTitle forState:UIControlStateNormal];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,textPlaceholder)]) {
            self.textView.placeholder = self.viewModel.textPlaceholder;
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,attributedTextPlaceholder)]) {
            if (KSTIsEmptyObject(self.viewModel.attributedTextPlaceholder)) {
                self.textView.placeholder = self.viewModel.textPlaceholder;
            }
            else {
                self.textView.attributedPlaceholder = self.viewModel.attributedTextPlaceholder;
            }
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,automaticallyShowHideDoneButton)]) {
            [self _updateDoneButtonHiddenAnimated:shouldAnimate];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,doneAction.enabled)]) {
            [self _updateDoneButtonHiddenAnimated:shouldAnimate];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,editing)]) {
            [self _updateForEditingAnimated:shouldAnimate];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,leadingAccessoryViews)]) {
            for (UIView *view in self.leadingAccessoryStackView.subviews) {
                [view removeFromSuperview];
            }

            if (self.viewModel.leadingAccessoryViews.count > 0) {
                if (self.leadingAccessoryStackView == nil) {
                    self.leadingAccessoryStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
                    self.leadingAccessoryStackView.translatesAutoresizingMaskIntoConstraints = NO;
                    self.leadingAccessoryStackView.axis = UILayoutConstraintAxisHorizontal;
                    self.leadingAccessoryStackView.alignment = UIStackViewAlignmentLeading;
                    self.leadingAccessoryStackView.spacing = 8.0;
                    [self.inputStackView insertArrangedSubview:self.leadingAccessoryStackView atIndex:0];
                }

                for (UIView *view in self.viewModel.leadingAccessoryViews) {
                    [view setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
                    [self.leadingAccessoryStackView addArrangedSubview:view];
                }
            }
            else {
                [self.leadingAccessoryStackView removeFromSuperview];
                self.leadingAccessoryStackView = nil;
            }
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,typingIndicatorView)]) {
            [self _updateTypingIndicatorViewAnimated:shouldAnimate];
        }
    }];
    
    return self;
}

- (void)showKeyboard; {
    [self.textView becomeFirstResponder];
}
- (void)hideKeyboard; {
    [self.textView resignFirstResponder];
}

- (void)_updateDoneButtonHiddenAnimated:(BOOL)animated; {
    BOOL isHidden = self.doneButton.isHidden;
    BOOL hidden = self.viewModel.isEditing || (self.viewModel.automaticallyShowHideDoneButton && !self.viewModel.doneAction.enabled);
    
    if (isHidden == hidden) {
        return;
    }
    
    void(^block)(void) = ^{
        self.doneButton.hidden = hidden;
        self.doneButton.alpha = hidden ? 0.0 : 1.0;
        [self.inputStackView layoutIfNeeded];
    };
    
    if (animated) {
        [UIView animateWithDuration:self.viewModel.theme.animationDuration delay:0 usingSpringWithDamping:self.viewModel.theme.animationSpringDamping initialSpringVelocity:self.viewModel.theme.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:block completion:nil];
    }
    else {
        block();
    }
}
- (void)_updateForEditingAnimated:(BOOL)animated; {
    void(^block)(void) = ^{
        for (UIView *view in self.inputStackView.arrangedSubviews) {
            if ([view isKindOfClass:UIScrollView.class]) {
                break;
            }
            view.hidden = self.viewModel.isEditing;
            view.alpha = self.viewModel.isEditing ? 0.0 : 1.0;
        }
        
        self.doneButton.hidden = self.viewModel.isEditing;
        self.doneButton.alpha = self.viewModel.isEditing ? 0.0 : 1.0;
        
        self.editingView.hidden = !self.viewModel.isEditing;
        self.editingView.alpha = self.viewModel.isEditing ? 1.0 : 0.0;
        
        [self.stackView layoutIfNeeded];
        [self.inputStackView layoutIfNeeded];
    };
    
    if (animated) {
        [UIView animateWithDuration:self.viewModel.theme.animationDuration delay:0 usingSpringWithDamping:self.viewModel.theme.animationSpringDamping initialSpringVelocity:self.viewModel.theme.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:block completion:nil];
    }
    else {
        block();
    }
}
- (void)_updateTypingIndicatorViewAnimated:(BOOL)animated; {
    kstWeakify(self);
    
    [self.typingIndicatorView removeFromSuperview];
    self.typingIndicatorView = nil;
    
    if (self.viewModel.typingIndicatorView != nil) {
        self.typingIndicatorView = self.viewModel.typingIndicatorView;
        if ([self.typingIndicatorView respondsToSelector:@selector(theme)]) {
            self.typingIndicatorView.theme = self.viewModel.theme;
        }
        [self.containingStackView insertArrangedSubview:self.typingIndicatorView atIndex:0];
    }
    
    if (animated) {
        [UIView animateWithDuration:self.viewModel.theme.animationDuration delay:0 usingSpringWithDamping:self.viewModel.theme.animationSpringDamping initialSpringVelocity:self.viewModel.theme.animationInitialSpringVelocity options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            kstStrongify(self);
            [self.containingStackView layoutIfNeeded];
        } completion:nil];
    }
}

@end
