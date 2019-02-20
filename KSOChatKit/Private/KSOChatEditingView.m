//
//  KSOChatEditingView.m
//  KSOChatKit
//
//  Created by William Towe on 3/5/18.
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

#import "KSOChatEditingView.h"
#import "KSOChatViewModel.h"
#import "KSOChatTheme.h"

#import <Ditko/Ditko.h>
#import <Agamotto/Agamotto.h>
#import <Stanley/Stanley.h>

@interface KSOChatEditingView ()
@property (strong,nonatomic) UIStackView *stackView;

@property (strong,nonatomic) UIButton *cancelButton;
@property (strong,nonatomic) UILabel *label;
@property (strong,nonatomic) UIButton *doneButton;

@property (strong,nonatomic) KSOChatViewModel *viewModel;
@end

@implementation KSOChatEditingView

- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel; {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    kstWeakify(self);
    
    _viewModel = viewModel;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = UIColor.clearColor;
    
    _stackView = [[UIStackView alloc] initWithFrame:CGRectZero];
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    _stackView.axis = UILayoutConstraintAxisHorizontal;
    _stackView.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_stackView];
    
    _cancelButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    _cancelButton.titleLabel.font = _viewModel.theme.buttonFont;
    _cancelButton.KAG_action = _viewModel.cancelAction;
    [_cancelButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_stackView addArrangedSubview:_cancelButton];
    
    _label = [[UILabel alloc] initWithFrame:CGRectZero];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.textColor = _viewModel.theme.textColor;
    _label.font = _viewModel.theme.buttonFont;
    [_label setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_stackView addArrangedSubview:_label];
    
    _doneButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    _doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    _doneButton.titleLabel.font = _viewModel.theme.buttonFont;
    _doneButton.KAG_action = _viewModel.doneAction;
    [_doneButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [_stackView addArrangedSubview:_doneButton];
    
    if (_viewModel.theme.buttonTextStyle != nil) {
        [NSObject KDI_registerDynamicTypeObjects:@[_cancelButton.titleLabel,_label,_doneButton.titleLabel] forTextStyle:_viewModel.theme.buttonTextStyle];
    }
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": _stackView}]];
    
    [_viewModel KAG_addObserverForKeyPaths:@[@kstKeypath(_viewModel,editingTitle),@kstKeypath(_viewModel,editingCancelButtonTitle),@kstKeypath(_viewModel,editingDoneButtonTitle)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        if ([keyPath isEqualToString:@kstKeypath(self.viewModel,editingTitle)]) {
            self.label.text = self.viewModel.editingTitle;
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,editingCancelButtonTitle)]) {
            [self.cancelButton setTitle:self.viewModel.editingCancelButtonTitle forState:UIControlStateNormal];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self.viewModel,editingDoneButtonTitle)]) {
            [self.doneButton setTitle:self.viewModel.editingDoneButtonTitle forState:UIControlStateNormal];
        }
    }];
    
    return self;
}

@end
