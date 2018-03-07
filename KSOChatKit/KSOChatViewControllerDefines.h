//
//  KSOChatViewControllerDefines.h
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

#ifndef __KSO_CHAT_KIT_DEFINES__
#define __KSO_CHAT_KIT_DEFINES__

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, KSOChatViewControllerOptions) {
    KSOChatViewControllerOptionsNone = 0,
    KSOChatViewControllerOptionsAutomaticallyShowHideDoneButton = 1 << 0,
    KSOChatViewControllerOptionsAutomaticallyScrollToBottomOnKeyboardWillShow = 1 << 1,
    KSOChatViewControllerOptionsAll = KSOChatViewControllerOptionsAutomaticallyShowHideDoneButton|KSOChatViewControllerOptionsAutomaticallyScrollToBottomOnKeyboardWillShow
};

typedef NS_OPTIONS(NSUInteger, KSOChatViewControllerMediaTypes) {
    KSOChatViewControllerMediaTypesNone = 0,
    KSOChatViewControllerMediaTypesPlainText = 1 << 0,
    KSOChatViewControllerMediaTypesPNG = 1 << 1,
    KSOChatViewControllerMediaTypesJPEG = 1 << 2,
    KSOChatViewControllerMediaTypesTIFF = 1 << 3,
    KSOChatViewControllerMediaTypesGIF = 1 << 4,
    KSOChatViewControllerMediaTypesMOV = 1 << 5,
    KSOChatViewControllerMediaTypesPassbook = 1 << 6,
    KSOChatViewControllerMediaTypesImages = KSOChatViewControllerMediaTypesPNG|KSOChatViewControllerMediaTypesJPEG|KSOChatViewControllerMediaTypesTIFF|KSOChatViewControllerMediaTypesGIF,
    KSOChatViewControllerMediaTypesVideos = KSOChatViewControllerMediaTypesMOV,
    KSOChatViewControllerMediaTypesAll = KSOChatViewControllerMediaTypesPlainText|KSOChatViewControllerMediaTypesPNG|KSOChatViewControllerMediaTypesJPEG|KSOChatViewControllerMediaTypesTIFF|KSOChatViewControllerMediaTypesGIF|KSOChatViewControllerMediaTypesMOV|KSOChatViewControllerMediaTypesPassbook
};

FOUNDATION_EXTERN NSArray<NSString*>* KSOChatViewControllerUTIsForMediaTypes(KSOChatViewControllerMediaTypes mediaTypes);
FOUNDATION_EXTERN KSOChatViewControllerMediaTypes KSOChatViewControllerMediaTypesFromUTIs(NSArray<NSString *> *UTIs);

FOUNDATION_EXTERN NSString *const KSOChatViewControllerUTIPassbook;

#endif
