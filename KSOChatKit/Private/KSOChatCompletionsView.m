//
//  KSOChatCompletionsView.m
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

#import "KSOChatCompletionsView.h"
#import "KSOChatViewModel.h"
#import "KSOChatDefaultCompletionTableViewCell.h"
#import "KSOChatViewController.h"
#import "KSOChatTheme.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatCompletionsView () <KSOChatViewModelViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;
@property (copy,nonatomic) NSArray<id<KSOChatCompletion>> *completions;
@property (strong,nonatomic) NSMutableSet<Class<KSOChatCompletionCell>> *registeredCompletionCellClasses;

@property (strong,nonatomic) NSLayoutConstraint *tableViewHeightLayoutConstraint;

@end

@implementation KSOChatCompletionsView

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window != nil) {
        if ([self.viewModel.delegate respondsToSelector:@selector(chatViewController:willShowCompletionsTableView:)]) {
            [self.viewModel.delegate chatViewController:self.viewModel.chatViewController willShowCompletionsTableView:self.tableView];
        }
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.completions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = NSStringFromClass(KSOChatDefaultCompletionTableViewCell.class);
    NSString *prefix;
    if ([self.viewModel shouldShowCompletionsForRange:self.viewModel.selectedRange prefix:&prefix text:NULL range:NULL]) {
        if (self.viewModel.prefixesToCompletionCellClasses[prefix] != nil) {
            Class<KSOChatCompletionCell> completionCellClass = self.viewModel.prefixesToCompletionCellClasses[prefix];
            
            if (![self.registeredCompletionCellClasses containsObject:completionCellClass]) {
                [self.registeredCompletionCellClasses addObject:completionCellClass];
                
                [tableView registerClass:completionCellClass forCellReuseIdentifier:NSStringFromClass(completionCellClass)];
            }
            
            identifier = NSStringFromClass(completionCellClass);
        }
    }
    UITableViewCell<KSOChatCompletionCell> *retval = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    id<KSOChatCompletion> completion = self.completions[indexPath.row];
    
    retval.chatCompletion = completion;
    
    return retval;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel selectCompletion:self.completions[indexPath.row]];
}

#pragma mark KSOChatViewModelViewDelegate
- (void)chatViewModelShowCompletions:(KSOChatViewModel *)chatViewModel {
    [self.viewModel requestCompletionsWithCompletion:^(NSArray<id<KSOChatCompletion>> *completions) {
        self.completions = completions;
    }];
}

- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    kstWeakify(self);
    
    _viewModel = viewModel;
    [_viewModel addViewDelegate:self];
    
    _registeredCompletionCellClasses = [[NSMutableSet alloc] init];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = UIColor.whiteColor;
    self.borderColor = KDIColorW(0.85);
    self.borderOptions = KDIBorderOptionsTop;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.estimatedRowHeight = 44.0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:KSOChatDefaultCompletionTableViewCell.class forCellReuseIdentifier:NSStringFromClass(KSOChatDefaultCompletionTableViewCell.class)];
    [self addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _tableView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[view]|" options:0 metrics:@{@"margin": @1.0} views:@{@"view": _tableView}]];
    
    _tableViewHeightLayoutConstraint = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ceil(_tableView.estimatedRowHeight * 2.5)];
    _tableViewHeightLayoutConstraint.priority = UILayoutPriorityRequired - 1.0;
    [NSLayoutConstraint activateConstraints:@[_tableViewHeightLayoutConstraint]];
    
    [_viewModel requestCompletionsWithCompletion:^(NSArray<id<KSOChatCompletion>> *completions) {
        kstStrongify(self);
        self.completions = completions;
    }];
    
    [self KAG_addObserverForKeyPaths:@[@kstKeypath(self,completions),@kstKeypath(self,tableView.contentSize)] options:0 block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        if ([keyPath isEqualToString:@kstKeypath(self,completions)]) {
            [self.tableView reloadData];
        }
        else if ([keyPath isEqualToString:@kstKeypath(self,tableView.contentSize)]) {
            CGFloat maximumHeight = ceil(self.tableView.estimatedRowHeight * 2.5);
            
            self.tableViewHeightLayoutConstraint.constant = MIN(self.tableView.contentSize.height, maximumHeight);
        }
    }];
    
    return self;
}

@end
