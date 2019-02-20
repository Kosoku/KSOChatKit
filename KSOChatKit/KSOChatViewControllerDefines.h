//
//  KSOChatViewControllerDefines.h
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
