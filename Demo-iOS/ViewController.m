//
//  ViewController.m
//  Demo-iOS
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

#import "ViewController.h"

#import <KSOChatKit/KSOChatKit.h>
#import <Ditko/Ditko.h>

@interface ContentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (readonly,nonatomic) UITableView *tableView;
@property (readonly,nonatomic) NSInteger numberOfRows;
@end

@implementation ContentViewController
- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}
- (void)loadView {
    self.view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44.0;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    retval.textLabel.text = [NSNumberFormatter localizedStringFromNumber:@(indexPath.row) numberStyle:NSNumberFormatterSpellOutStyle];
    
    return retval;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = KDIColorRandomRGB();
}

- (UITableView *)tableView {
    return (UITableView *)self.view;
}
- (NSInteger)numberOfRows {
    return 25;
}
@end

@interface ViewController () <KSOChatViewControllerDelegate>
@property (strong,nonatomic) KSOChatViewController *chatViewController;
@property (strong,nonatomic) UINavigationController *contentViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatViewController = [[KSOChatViewController alloc] initWithNibName:nil bundle:nil];
    self.chatViewController.title = @"Chats";
    self.chatViewController.delegate = self;
    self.chatViewController.contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    
    self.contentViewController = [[UINavigationController alloc] initWithRootViewController:self.chatViewController];
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
}

- (void)chatViewControllerDidTapDoneButton:(KSOChatViewController *)chatViewController completion:(KSOChatViewControllerCompletionBlock)completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion(YES);
    });
}

@end
