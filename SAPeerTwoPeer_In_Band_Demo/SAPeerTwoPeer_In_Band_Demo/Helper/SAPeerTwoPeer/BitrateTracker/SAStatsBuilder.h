//
//  SAStatsBuilder.h
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/23/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Class used to accumulate stats information into a single displayable string.
 */
@interface SAStatsBuilder : NSObject

/** String that represents the accumulated stats reports passed into this
 *  class.
 */
@property(nonatomic, readonly) NSString *statsString;

/** Parses the information in the stats report into an appropriate internal
 *  format used to generate the stats string.
 */
- (void)parseStatsReport:(RTCLegacyStatsReport *)statsReport;

@end
