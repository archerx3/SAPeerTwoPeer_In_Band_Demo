//
//  RTCSessionDescription+JSON.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <WebRTC/WebRTC.h>

@interface RTCSessionDescription (JSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary;
- (NSData *)JSONData;

@end
