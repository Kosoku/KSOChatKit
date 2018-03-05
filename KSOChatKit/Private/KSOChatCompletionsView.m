//
//  KSOChatCompletionsView.m
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

#import "KSOChatCompletionsView.h"
#import "KSOChatViewModel.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Agamotto/Agamotto.h>

@interface KSOChatCompletionsView () <KSOChatViewModelViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;

@property (strong,nonatomic) KSOChatViewModel *viewModel;
@property (copy,nonatomic) NSArray<id<KSOChatCompletion>> *completions;

@end

@implementation KSOChatCompletionsView

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.completions.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KDITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(KDITableViewCell.class) forIndexPath:indexPath];
    id<KSOChatCompletion> completion = self.completions[indexPath.row];
    
    retval.title = completion.chatCompletionTitle;
    
    return retval;
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark KSOChatViewModelViewDelegate
- (void)chatViewModelShowCompletions:(KSOChatViewModel *)chatViewModel {
    self.hidden = NO;
    
    [self.viewModel requestCompletionsWithCompletion:^(NSArray<id<KSOChatCompletion>> *completions) {
        self.completions = completions;
    }];
}
- (void)chatViewModelHideCompletions:(KSOChatViewModel *)chatViewModel {
    self.hidden = YES;
}

- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    kstWeakify(self);
    
    _viewModel = viewModel;
    [_viewModel addViewDelegate:self];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.hidden = YES;
    self.backgroundColor = UIColor.clearColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.estimatedRowHeight = 44.0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:KDITableViewCell.class forCellReuseIdentifier:NSStringFromClass(KDITableViewCell.class)];
    [self addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _tableView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(==height@priority)]|" options:0 metrics:@{@"height": @(ceil(_tableView.estimatedRowHeight * 2.0)), @"priority": @(UILayoutPriorityRequired - 1.0)} views:@{@"view": _tableView}]];
    
    [self KAG_addObserverForKeyPaths:@[@kstKeypath(self,completions)] options:0 block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        [self.tableView reloadData];
    }];
    
    return self;
}

@end
