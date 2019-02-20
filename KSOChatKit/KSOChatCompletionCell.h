//
//  KSOChatCompletionCell.h
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

#import <Foundation/Foundation.h>
#import <KSOChatKit/KSOChatCompletion.h>

/**
 Protocol describing a table view cell that can display a completion object.
 */
@protocol KSOChatCompletionCell <NSObject>
@required
/**
 Set and get the completion object represented by the receiver.
 */
@property (strong,nonatomic) id<KSOChatCompletion> chatCompletion;
@end
