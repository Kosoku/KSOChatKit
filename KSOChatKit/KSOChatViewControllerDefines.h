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

/**
 Options mask for chat view controller behavior.
 */
typedef NS_OPTIONS(NSUInteger, KSOChatViewControllerOptions) {
    /**
     No behavior.
     */
    KSOChatViewControllerOptionsNone = 0,
    /**
     The chat view controller will automatically show/hide the done button anchored against the trailing edge of the input view when the user enters text. The done button will be hidden by default.
     */
    KSOChatViewControllerOptionsAutomaticallyShowHideDoneButton = 1 << 0,
    /**
     The chat view controller will automatically scroll the scroll view returned by the its delegate to the bottom when showing the keyboard.
     */
    KSOChatViewControllerOptionsAutomaticallyScrollToBottomOnKeyboardWillShow = 1 << 1,
    /**
     Specify all behavior.
     */
    KSOChatViewControllerOptionsAll = KSOChatViewControllerOptionsAutomaticallyShowHideDoneButton|KSOChatViewControllerOptionsAutomaticallyScrollToBottomOnKeyboardWillShow
};

/**
 Options mask for media types that can be pasted into the chat text view.
 */
typedef NS_OPTIONS(NSUInteger, KSOChatViewControllerMediaTypes) {
    /**
     Nothing can be pasted.
     */
    KSOChatViewControllerMediaTypesNone = 0,
    /**
     Plain text can be pasted. You probably shouldn't disable this.
     */
    KSOChatViewControllerMediaTypesPlainText = 1 << 0,
    /**
     PNG images can be pasted.
     */
    KSOChatViewControllerMediaTypesPNG = 1 << 1,
    /**
     JPEG images can be pasted.
     */
    KSOChatViewControllerMediaTypesJPEG = 1 << 2,
    /**
     TIFF images can be pasted.
     */
    KSOChatViewControllerMediaTypesTIFF = 1 << 3,
    /**
     GIF images can be pasted.
     */
    KSOChatViewControllerMediaTypesGIF = 1 << 4,
    /**
     MOV video files can be pasted.
     */
    KSOChatViewControllerMediaTypesMOV = 1 << 5,
    /**
     Passbook files can be pasted.
     */
    KSOChatViewControllerMediaTypesPassbook = 1 << 6,
    /**
     All image types can be pasted.
     */
    KSOChatViewControllerMediaTypesImages = KSOChatViewControllerMediaTypesPNG|KSOChatViewControllerMediaTypesJPEG|KSOChatViewControllerMediaTypesTIFF|KSOChatViewControllerMediaTypesGIF,
    /**
     All video types can be pasted.
     */
    KSOChatViewControllerMediaTypesVideos = KSOChatViewControllerMediaTypesMOV,
    /**
     All types can be pasted.
     */
    KSOChatViewControllerMediaTypesAll = KSOChatViewControllerMediaTypesPlainText|KSOChatViewControllerMediaTypesPNG|KSOChatViewControllerMediaTypesJPEG|KSOChatViewControllerMediaTypesTIFF|KSOChatViewControllerMediaTypesGIF|KSOChatViewControllerMediaTypesMOV|KSOChatViewControllerMediaTypesPassbook
};

/**
 Returns an array of UTIs for the provided pastable media types.
 
 @param mediaTypes The media types
 @return The array of UTIs
 */
FOUNDATION_EXTERN NSArray<NSString*>* KSOChatViewControllerUTIsForMediaTypes(KSOChatViewControllerMediaTypes mediaTypes);
/**
 Returns the pastable media types for the array of UTIs.
 
 @param UTIs The array of UTIs
 @return The pastable media types
 */
FOUNDATION_EXTERN KSOChatViewControllerMediaTypes KSOChatViewControllerMediaTypesFromUTIs(NSArray<NSString *> *UTIs);

/**
 The UTI for passbook files.
 */
FOUNDATION_EXTERN NSString *const KSOChatViewControllerUTIPassbook;

#endif
