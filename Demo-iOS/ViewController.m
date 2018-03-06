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
#import "LoremIpsum.h"

#import <KSOChatKit/KSOChatKit.h>
#import <Ditko/Ditko.h>
#import <KSOFontAwesomeExtensions/KSOFontAwesomeExtensions.h>
#import <Stanley/Stanley.h>

@interface User : NSObject <KSOChatCompletion>
@property (copy,nonatomic) NSString *name;
@property (copy,nonatomic) NSString *screenName;
@property (strong,nonatomic) UIImage *image;
@end

@implementation User
- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _name = [LoremIpsum name];
    _screenName = [@"@" stringByAppendingString:[LoremIpsum firstName]];
    
    return self;
}

- (NSString *)chatCompletionTitle {
    return self.name;
}
- (NSString *)chatCompletionSubtitle {
    return self.screenName;
}
- (UIImage *)image {
    if (_image == nil) {
        CGSize size = CGSizeMake(32, 32);
        UIGraphicsBeginImageContext(size);
        
        [KDIColorRandomRGB() setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        
        UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        _image = retval;
    }
    return _image;
}
@end

@interface HashTag : NSObject <KSOChatCompletion>
@property (copy,nonatomic) NSString *name;
@end

@implementation HashTag
- (instancetype)init {
    if (!(self = [super init]))
        return nil;
    
    _name = [@"#" stringByAppendingString:[LoremIpsum word]];
    
    return self;
}

- (NSString *)chatCompletionTitle {
    return self.name;
}
@end

@interface Message : NSObject
@property (copy,nonatomic) NSString *text;
@property (strong,nonatomic) User *user;
- (instancetype)initWithText:(NSString *)text;
@end

@implementation Message
- (instancetype)init {
    return [self initWithText:nil];
}
- (instancetype)initWithText:(NSString *)text {
    if (!(self = [super init]))
        return nil;
    
    _text = text ?: [LoremIpsum sentence];
    _user = [[User alloc] init];
    
    return self;
}
@end

@interface UserTableViewCell : KDITableViewCell <KSOChatCompletionCell>
@end

@implementation UserTableViewCell
@synthesize completion=_completion;
- (void)setCompletion:(id<KSOChatCompletion>)completion {
    _completion = completion;
    
    User *user = (User *)_completion;
    
    self.title = user.name;
    self.subtitle = user.screenName;
    self.icon = user.image;
}
@end

@interface ContentViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) UITableView *tableView;

@property (copy,nonatomic) NSArray<Message *> *messages;
@property (strong,nonatomic) Message *editingMessage;

- (void)addMessageWithText:(NSString *)text;
@end

@implementation ContentViewController
- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (NSUInteger i=0; i<15; i++) {
        [temp addObject:[[Message alloc] init]];
    }
    
    self.messages = temp;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = 44.0;
    [self.tableView registerClass:KDITableViewCell.class forCellReuseIdentifier:NSStringFromClass(KDITableViewCell.class)];
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
    KDITableViewCell *retval = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(KDITableViewCell.class) forIndexPath:indexPath];
    
    retval.title = self.messages[indexPath.row].user.name;
    retval.subtitle = self.messages[indexPath.row].text;
    retval.icon = self.messages[indexPath.row].user.image;
    
    return retval;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.editingMessage = self.messages[indexPath.row];
    
    [self.KSO_chatViewController editText:self.editingMessage.text];
}

- (void)addMessageWithText:(NSString *)text {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.messages];
    
    [temp addObject:[[Message alloc] initWithText:text]];
    
    self.messages = temp;
    
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)editMessageWithText:(NSString *)text {
    self.editingMessage.text = text;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.messages indexOfObject:self.editingMessage] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.editingMessage = nil;
}

@end

@interface ViewController () <KSOChatViewControllerDelegate>
@property (strong,nonatomic) KSOChatViewController *chatViewController;
@property (strong,nonatomic) UINavigationController *contentViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addButton setImage:[UIImage KSO_fontAwesomeImageWithIcon:KSOFontAwesomeIconPlus size:CGSizeMake(25, 25)].KDI_templateImage forState:UIControlStateNormal];
    [addButton KDI_addBlock:^(__kindof UIControl * _Nonnull control, UIControlEvents controlEvents) {
        [UIAlertController KDI_presentAlertControllerWithTitle:nil message:@"The add button was tapped!" cancelButtonTitle:nil otherButtonTitles:nil completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.chatViewController = [[KSOChatViewController alloc] initWithNibName:nil bundle:nil];
    self.chatViewController.title = @"Chats";
    self.chatViewController.prefixesForCompletion = [NSSet setWithArray:@[@"@",@"#",@"/"]];
    self.chatViewController.delegate = self;
    self.chatViewController.contentViewController = [[ContentViewController alloc] initWithNibName:nil bundle:nil];
    self.chatViewController.markdownSymbolsToTitles = @[@{@"**": @"Bold"},
                                                        @{@"_": @"Italic"},
                                                        @{@"~~": @"Strike"},
                                                        @{@"`": @"Code"},
                                                        @{@"```": @"Preformatted"},
                                                        @{@"> ": @"Quote"}];
    self.chatViewController.leadingAccessoryViews = @[addButton];
    [self.chatViewController addSyntaxHighlightingRegularExpression:[NSRegularExpression regularExpressionWithPattern:@"#\\w+" options:0 error:NULL] textAttributes:@{NSForegroundColorAttributeName: UIColor.orangeColor}];
    [self.chatViewController addSyntaxHighlightingRegularExpression:[NSRegularExpression regularExpressionWithPattern:@"@\\w+" options:0 error:NULL] textAttributes:@{NSForegroundColorAttributeName: UIColor.redColor}];
    [self.chatViewController setCompletionCellClass:UserTableViewCell.class forPrefix:@"@"];
    
    self.contentViewController = [[UINavigationController alloc] initWithRootViewController:self.chatViewController];
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.contentViewController];
    [self.view addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.contentViewController.view}]];
    
    KDIButton *bottomButton = [KDIButton buttonWithType:UIButtonTypeSystem];
    
    bottomButton.translatesAutoresizingMaskIntoConstraints = NO;
    bottomButton.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
    [bottomButton setImage:[UIImage KSO_fontAwesomeImageWithIcon:KSOFontAwesomeIconCog size:CGSizeMake(25, 25)].KDI_templateImage forState:UIControlStateNormal];
    bottomButton.inverted = YES;
    [self.chatViewController.view addSubview:bottomButton];
    
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]" options:0 metrics:nil views:@{@"view": bottomButton}]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view][bottom]" options:0 metrics:nil views:@{@"view": bottomButton, @"bottom": self.chatViewController.chatBottomLayoutGuide}]];
}

- (UIScrollView *)scrollViewForChatViewController:(KSOChatViewController *)chatViewController {
    return [(ContentViewController *)chatViewController.contentViewController tableView];
}

- (BOOL)chatViewControllerReturnShouldTapDoneButton:(KSOChatViewController *)chatViewController {
    return YES;
}
- (void)chatViewControllerDidTapDoneButton:(KSOChatViewController *)chatViewController completion:(KSOChatViewControllerCompletionBlock)completion {
    ContentViewController *viewController = chatViewController.contentViewController;
    
    if (chatViewController.isEditing) {
        [viewController editMessageWithText:chatViewController.text];
    }
    else {
        [viewController addMessageWithText:chatViewController.text];
        
        [viewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:viewController.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    completion(YES);
}

- (void)chatViewControllerDidChangeText:(KSOChatViewController *)chatViewController {
//    KSTLog(@"text=%@",chatViewController.text);
}

- (void)chatViewController:(KSOChatViewController *)chatViewController didPasteMediaType:(KSOChatViewControllerMediaTypes)mediaType data:(NSData *)data {
    KSTLogObject(KSOChatViewControllerUTIsForMediaTypes(mediaType));
}

- (BOOL)chatViewController:(KSOChatViewController *)chatViewController shouldShowCompletionsForPrefix:(NSString *)prefix text:(NSString *)text {
    return YES;
}
- (NSArray<id<KSOChatCompletion>> *)chatViewController:(KSOChatViewController *)chatViewController completionsForPrefix:(NSString *)prefix text:(NSString *)text {
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    if ([prefix isEqualToString:@"@"]) {
        for (NSUInteger i=0; i<10; i++) {
            [retval addObject:[[User alloc] init]];
        }
    }
    else if ([prefix isEqualToString:@"#"]) {
        for (NSUInteger i=0; i<10; i++) {
            [retval addObject:[[HashTag alloc] init]];
        }
    }
    
    return retval;
}
- (NSString *)chatViewController:(KSOChatViewController *)chatViewController textForCompletion:(id<KSOChatCompletion>)completion {
    if ([completion isKindOfClass:User.class]) {
        User *user = (User *)completion;
        
        return user.screenName;
    }
    else if ([completion isKindOfClass:HashTag.class]) {
        HashTag *hashtag = (HashTag *)completion;
        
        return hashtag.name;
    }
    return @"";
}

@end
