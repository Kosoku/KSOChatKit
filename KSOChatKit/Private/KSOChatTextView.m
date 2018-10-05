//
//  KSOChatTextView.m
//  KSOChatKit
//
//  Created by William Towe on 3/6/18.
//  Copyright © 2018 Kosoku Interactive, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "KSOChatTextView.h"
#import "KSOChatViewModel.h"
#import "KSOChatTheme.h"
#import "NSBundle+KSOChatKitExtensionsPrivate.h"

#import <Ditko/Ditko.h>
#import <Stanley/Stanley.h>
#import <Quicksilver/Quicksilver.h>
#import <Agamotto/Agamotto.h>

static NSString *const kMarkdownSelectorPrefix = @"__KSOChatKit_markdown__";

static SEL KSOChatTextViewSelectorFromMarkdownTitle(NSString *markdownTitle) {
    return NSSelectorFromString([NSString stringWithFormat:@"%@%@",kMarkdownSelectorPrefix,markdownTitle]);
}
static NSString* KSOChatTextViewMarkdownTitleFromSelector(SEL selector) {
    NSString *title = NSStringFromSelector(selector);
    NSRange range = [title rangeOfString:kMarkdownSelectorPrefix];
    
    if (range.length > 0) {
        return [title substringFromIndex:NSMaxRange(range)];
    }
    return nil;
}

@interface KSOChatTextView ()
@property (strong,nonatomic) KSOChatViewModel *viewModel;
@property (assign,nonatomic,getter=isShowingMarkdownMenu) BOOL showingMarkdownMenu;

- (void)_addMarkdownMenuItem;
- (void)_applyMarkdownSymbolForTitle:(NSString *)title;
- (NSString *)_pasteboardSupportedUTI;
@end

@implementation KSOChatTextView

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *retval = [super methodSignatureForSelector:aSelector];
    
    if (retval == nil) {
        retval = [super methodSignatureForSelector:@selector(_applyMarkdownSymbolForTitle:)];
    }
    
    return retval;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSString *title = KSOChatTextViewMarkdownTitleFromSelector(anInvocation.selector);
    
    if (title.length > 0) {
        [self _applyMarkdownSymbolForTitle:title];
    }
    else {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)canBecomeFirstResponder {
    BOOL retval = [super canBecomeFirstResponder];
    
    if (retval) {
        [self _addMarkdownMenuItem];
    }
    
    return retval;
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (self.isShowingMarkdownMenu) {
        NSString *title = KSOChatTextViewMarkdownTitleFromSelector(action);
        
        if (title.length > 0) {
            if ([self.viewModel.delegate respondsToSelector:@selector(chatViewController:shouldShowMenuItemForMarkdownSymbol:)]) {
                NSString *symbol = [self.viewModel.markdownSymbolsToTitles KQS_find:^BOOL(NSDictionary<NSString *,NSString *> * _Nonnull object, NSInteger index) {
                    return [object.allValues.firstObject isEqualToString:title];
                }].allKeys.firstObject;
                
                return [self.viewModel.delegate chatViewController:self.viewModel.chatViewController shouldShowMenuItemForMarkdownSymbol:symbol];
            }
            return YES;
        }
        return NO;
    }
    
    if (action == @selector(paste:)) {
        return [self _pasteboardSupportedUTI] != nil;
    }
    else if (action == @selector(_markdownMenuItemAction:)) {
        return self.selectedRange.length > 0;
    }
    return [super canPerformAction:action withSender:sender];
}
- (void)paste:(id)sender {
    NSString *string = nil;
    
    if (UIPasteboard.generalPasteboard.URL != nil) {
        string = UIPasteboard.generalPasteboard.URL.absoluteString;
    }
    else if (UIPasteboard.generalPasteboard.string != nil) {
        string = UIPasteboard.generalPasteboard.string;
    }
    
    if (string == nil) {
        NSString *UTI = [self _pasteboardSupportedUTI];
        NSData *data = [UIPasteboard.generalPasteboard dataForPasteboardType:UTI];
        
        if (data != nil) {
            if ([self.viewModel.delegate respondsToSelector:@selector(chatViewController:didPasteMediaType:data:)]) {
                [self.viewModel.delegate chatViewController:self.viewModel.chatViewController didPasteMediaType:KSOChatViewControllerMediaTypesFromUTIs(@[UTI]) data:data];
            }
        }
    }
    else {
        [self.viewModel insertTextAtSelectedRange:string];
    }
}

- (instancetype)initWithViewModel:(KSOChatViewModel *)viewModel; {
    if (!(self = [super initWithFrame:CGRectZero textContainer:nil]))
        return nil;
    
    kstWeakify(self);
    
    _viewModel = viewModel;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollEnabled = NO;
    self.backgroundColor = _viewModel.theme.textBackgroundColor;
    self.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.font = _viewModel.theme.textFont;
    self.placeholderTextColor = _viewModel.theme.textPlaceholderColor;
    if (_viewModel.theme.textStyle != nil) {
        self.KDI_dynamicTypeTextStyle = _viewModel.theme.textStyle;
    }
    self.KDI_cornerRadius = _viewModel.theme.textCornerRadius;
    
    [self.viewModel KAG_addObserverForKeyPaths:@[@kstKeypath(self.viewModel,allowsChatInputInteraction)] options:NSKeyValueObservingOptionInitial block:^(NSString * _Nonnull keyPath, id  _Nullable value, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        kstStrongify(self);
        if ([keyPath isEqualToString:@kstKeypath(self.viewModel,allowsChatInputInteraction)]) {
            self.editable = self.viewModel.allowsChatInputInteraction;
            self.selectable = self.viewModel.allowsChatInputInteraction;
        }
    }];
    
    [self KAG_addObserverForNotificationNames:@[UIMenuControllerDidHideMenuNotification] object:nil block:^(NSNotification * _Nonnull notification) {
        kstStrongify(self);
        self.showingMarkdownMenu = NO;
        
        [self _addMarkdownMenuItem];
    }];
    
    return self;
}

- (IBAction)_markdownMenuItemAction:(id)sender {
    self.showingMarkdownMenu = YES;
    
    NSArray *menuItems = [self.viewModel.markdownSymbolsToTitles KQS_map:^id _Nullable(NSDictionary<NSString *,NSString *> * _Nonnull object, NSInteger index) {
        return [[UIMenuItem alloc] initWithTitle:object.allValues.firstObject action:KSOChatTextViewSelectorFromMarkdownTitle(object.allValues.firstObject)];
    }];
    
    UIMenuController.sharedMenuController.menuItems = menuItems;
    
    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:self.selectedRange actualCharacterRange:NULL];
    CGRect targetRect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
    
    targetRect.origin.x += self.textContainerInset.left;
    targetRect.origin.y += self.textContainerInset.top;
    
    [UIMenuController.sharedMenuController setTargetRect:targetRect inView:self];
    [UIMenuController.sharedMenuController setMenuVisible:YES animated:YES];
}

- (void)_addMarkdownMenuItem; {
    if (self.viewModel.markdownSymbolsToTitles.count == 0) {
        return;
    }
    
    UIMenuItem *markdownItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"menu-item.markdown.title", nil, NSBundle.KSO_chatKitFrameworkBundle, @"Markdown", @"menu item markdown title") action:@selector(_markdownMenuItemAction:)];
    
    UIMenuController.sharedMenuController.menuItems = @[markdownItem];
}
- (void)_applyMarkdownSymbolForTitle:(NSString *)title; {
    NSString *symbol = [self.viewModel.markdownSymbolsToTitles KQS_find:^BOOL(NSDictionary<NSString *,NSString *> * _Nonnull object, NSInteger index) {
        return [object.allValues.firstObject isEqualToString:title];
    }].allKeys.firstObject;
    
    [self.viewModel applyMarkdownSymbolToSelectedRange:symbol];
}
- (NSString *)_pasteboardSupportedUTI; {
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    
    for (NSString *type in KSOChatViewControllerUTIsForMediaTypes(self.viewModel.pastableMediaTypes)) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"self == %@",type]];
    }
    
    return [UIPasteboard.generalPasteboard.pasteboardTypes filteredArrayUsingPredicate:[NSCompoundPredicate orPredicateWithSubpredicates:predicates]].firstObject;
}

@end
