//
//  RTCIceServer+JSON.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "RTCIceServer+JSON.h"

@implementation RTCIceServer (JSON)

+ (RTCIceServer *)defaultRTCIceServer
{
    NSArray *stunServer = @[@"stun:stun.l.google.com:19302",
                            @"stun:stun1.l.google.com:19302",
                            @"stun:stun2.l.google.com:19302",
                            @"stun:stun3.l.google.com:19302",
                            @"stun:stun3.l.google.com:19302",
                            @"stun:stun01.sipphone.com",
                            @"stun:stun.ekiga.net",
                            @"stun:stun.fwdnet.net",
                            @"stun:stun.fwdnet.net",
                            @"stun:stun.fwdnet.net",
                            @"stun:stun.ideasip.com",
                            @"stun:stun.iptel.org",
                            @"stun:stun.rixtelecom.se",
                            @"stun:stun.schlund.de",
                            @"stun:stunserver.org",
                            @"stun:stun.softjoys.com",
                            @"stun:stun.voiparound.com",
                            @"stun:stun.voipbuster.com",
                            @"stun:stun.voipstunt.com",
                            @"stun:stun.voxgratia.org",
                            @"stun:stun.xten.com",
                            @"stun:23.21.150.121",
                            @"stun:69.60.161.216"];

    
    RTCIceServer * iceServer = [[RTCIceServer alloc] initWithURLStrings:stunServer];
    
    return iceServer;
}

@end
