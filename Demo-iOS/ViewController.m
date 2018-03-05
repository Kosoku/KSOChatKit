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
#import <KSOFontAwesomeExtensions/KSOFontAwesomeExtensions.h>

@interface ContentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;

@property (copy,nonatomic) NSArray<NSString *> *messages;

- (void)addMessageWithText:(NSString *)text;
@end

@implementation ContentViewController
- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundView = ({
        KDIEmptyView *retval = [[KDIEmptyView alloc] initWithFrame:CGRectZero];
       
        retval.alignmentVertical = KDIEmptyViewAlignmentVerticalCustomSpacing;
        retval.alignmentVerticalCustomSpacing = 75.0;
        retval.image = [UIImage KSO_fontAwesomeImageWithString:@"\uf086" size:CGSizeMake(128, 128)];
        retval.headline = @"No Messages";
        retval.body = @"Add a message to see something!";
        
        retval;
    });
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = 44.0;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.tableView}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.tableView}]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    
    retval.textLabel.numberOfLines = 0;
    retval.textLabel.text = self.messages[indexPath.row];
    
    return retval;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.whiteColor : [KDIColorRandomRGB() colorWithAlphaComponent:0.5];
}

- (void)addMessageWithText:(NSString *)text {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.messages];
    
    [temp addObject:text];
    
    self.messages = temp;
    
    self.tableView.backgroundView.hidden = self.messages.count > 0;
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    self.chatViewController.prefixesForCompletion = [NSSet setWithArray:@[@"@",@"#",@"/"]];
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

- (BOOL)chatViewControllerReturnShouldTapDoneButton:(KSOChatViewController *)chatViewController {
    return YES;
}
- (void)chatViewControllerDidTapDoneButton:(KSOChatViewController *)chatViewController completion:(KSOChatViewControllerCompletionBlock)completion {
    ContentViewController *viewController = chatViewController.contentViewController;
    
    [viewController addMessageWithText:chatViewController.text];
    
    [viewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:viewController.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    completion(YES);
}

- (BOOL)chatViewController:(KSOChatViewController *)chatViewController shouldShowCompletionsForPrefix:(NSString *)prefix text:(NSString *)text {
    return YES;
}

@end
