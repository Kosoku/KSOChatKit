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
#import "KSOChatViewModel.h"
#import "KSOChatTheme.h"
#import "KSOChatEditingView.h"
#import "KSOChatTextView.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatInputView () <KSOChatViewModelDataSource,UITextViewDelegate,NSTextStorageDelegate>
@property (readwrite,strong,nonatomic) UILayoutGuide *chatInputTopLayoutGuide;

@property (strong,nonatomic) UIVisualEffectView *visualEffectView;
@property (strong,nonatomic) UIStackView *stackView;
@property (strong,nonatomic) UIStackView *inputStackView;
@property (strong,nonatomic) UIStackView *leadingAccessoryStackView;

@property (strong,nonatomic) KSOChatTextView *textView;
@property (strong,nonatomic) KDIButton *doneButton;
@property (strong,nonatomic) KSOChatEditingView *editingView;
@property (strong,nonatomic) UIView *typingIndicatorView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;

@end

@implementation KSOChatInputView
#pragma mark *** Subclass Overrides ***
- (BOOL)canBecomeFirstResponder {
    return self.textView.canBecomeFirstResponder;
}
- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}
- (BOOL)canResignFirstResponder {
    return self.textView.canResignFirstResponder;
}
- (BOOL)resignFirstResponder {
    return [self.textView resignFirstResponder];
}
#pragma mark -
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (void)updateConstraints {
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    if (self.typingIndicatorView != nil) {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.typingIndicatorView}]];
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]" options:0 metrics:nil views:@{@"view": self.typingIndicatorView}]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.visualEffectView}]];
    
    if (self.typingIndicatorView == nil) {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.visualEffectView}]];
    }
    else {
        [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[top][view]|" options:0 metrics:nil views:@{@"view": self.visualEffectView, @"top": self.typingIndicatorView}]];
    }
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view": self.stackView}]];
    
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.chatInputTopLayoutGuide}]];
    [temp addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": self.chatInputTopLayoutGuide, @"bottom": self.visualEffectView}]];
    
    self.KDI_customConstraints = temp;
    
    [super updateConstraints];
}
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
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent]];
    _visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_visualEffectView];
    
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
    
    _textView = [[KSOChatTextView alloc] initWithViewModel:self.viewModel];
    _textView.delegate = self;
    _textView.textStorage.delegate = self;
    [_inputStackView addArrangedSubview:_textView];
    
    _doneButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.titleLabel.font = _viewModel.theme.buttonFont;
    if (_viewModel.theme.buttonTextStyle != nil) {
        _doneButton.titleLabel.KDI_dynamicTypeTextStyle = _viewModel.theme.buttonTextStyle;
    }
    _doneButton.KAG_action = _viewModel.doneAction;
    [_inputStackView addArrangedSubview:_doneButton];
    
    _chatInputTopLayoutGuide = [[UILayoutGuide alloc] init];
    [self addLayoutGuide:_chatInputTopLayoutGuide];
    
    [_viewModel KAG_addObserverForKeyPaths:@[@kstKeypath(_viewModel,text),@kstKeypath(_viewModel,options),@kstKeypath(_viewModel,doneButtonTitle),@kstKeypath(_viewModel,textPlaceholder),@kstKeypath(_viewModel,editing),@kstKeypath(_viewModel,leadingAccessoryViews),@kstKeypath(_viewModel,typingIndicatorView)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        if ([keyPath isEqualToString:@kstKeypath(self.viewModel,text)]) {
            self.textView.text = self.viewModel.text;
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,options)]) {
            self.doneButton.hidden = (!(self.viewModel.options & KSOChatViewControllerOptionsShowDoneButton));
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,doneButtonTitle)]) {
            [self.doneButton setTitle:self.viewModel.doneButtonTitle forState:UIControlStateNormal];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,textPlaceholder)]) {
            self.textView.placeholder = self.viewModel.textPlaceholder;
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,editing)]) {
            self.doneButton.hidden = self.viewModel.isEditing;
            self.leadingAccessoryStackView.hidden = self.viewModel.isEditing;
            
            if (self.viewModel.isEditing) {
                if (self.editingView == nil) {
                    self.editingView = [[KSOChatEditingView alloc] initWithViewModel:self.viewModel];
                    [self.stackView insertArrangedSubview:self.editingView atIndex:0];
                }
                self.editingView.hidden = NO;
            }
            else {
                if (self.editingView != nil) {
                    [self.editingView removeFromSuperview];
                    self.editingView = nil;
                }
            }
            
            [self setNeedsUpdateConstraints];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,leadingAccessoryViews)]) {
            if (self.viewModel.leadingAccessoryViews.count > 0) {
                if (self.leadingAccessoryStackView == nil) {
                    self.leadingAccessoryStackView = [[UIStackView alloc] initWithFrame:CGRectZero];
                    self.leadingAccessoryStackView.translatesAutoresizingMaskIntoConstraints = NO;
                    self.leadingAccessoryStackView.axis = UILayoutConstraintAxisHorizontal;
                    self.leadingAccessoryStackView.alignment = UIStackViewAlignmentCenter;
                    self.leadingAccessoryStackView.spacing = 8.0;
                    [self.inputStackView insertArrangedSubview:self.leadingAccessoryStackView atIndex:0];
                }
                
                for (UIView *view in self.leadingAccessoryStackView.arrangedSubviews) {
                    [view removeFromSuperview];
                }
                
                for (UIView *view in self.viewModel.leadingAccessoryViews) {
                    [self.leadingAccessoryStackView addArrangedSubview:view];
                }
            }
            else {
                if (self.leadingAccessoryStackView != nil) {
                    [self.leadingAccessoryStackView removeFromSuperview];
                    self.leadingAccessoryStackView = nil;
                }
            }
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,typingIndicatorView)]) {
            [self.typingIndicatorView removeFromSuperview];
            self.typingIndicatorView = nil;
            
            if (self.viewModel.typingIndicatorView != nil) {
                self.typingIndicatorView = self.viewModel.typingIndicatorView;
                [self addSubview:self.typingIndicatorView];
            }
            
            [self setNeedsUpdateConstraints];
        }
    }];
    
    return self;
}

@end
