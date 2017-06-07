//
//  RTCIceCandidate+JSON.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <WebRTC/WebRTC.h>

@interface RTCIceCandidate (JSON)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;
+ (NSArray<RTCIceCandidate *> *)candidatesFromJSONDictionary:(NSDictionary *)dictionary;
+ (NSData *)JSONDataForIceCandidates:(NSArray<RTCIceCandidate *> *)candidates withType:(NSString *)typeValue;
- (NSData *)JSONData;

@end
