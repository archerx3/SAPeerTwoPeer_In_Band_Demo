//
//  SAPeerTwoPeerStatsView.m
//  SAPeerTwoPeer_Demo
//
//  Created by archer.chen on 5/22/17.
//  Copyright © 2017 archer.chen. All rights reserved.
//

#import "SAPeerTwoPeerStatsView.h"

//#import "SAStatsBuilder.h"

@implementation SAPeerTwoPeerStatsView
{
    UILabel         *mStatsLabel;
//    SAStatsBuilder  *mStatsBuilder;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        mStatsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        mStatsLabel.numberOfLines = 0;
        mStatsLabel.font = [UIFont fontWithName:@"Roboto" size:12];
        mStatsLabel.adjustsFontSizeToFitWidth = YES;
        mStatsLabel.minimumScaleFactor = 0.6;
        mStatsLabel.textColor = [UIColor greenColor];
        [self addSubview:mStatsLabel];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
//        mStatsBuilder = [[SAStatsBuilder alloc] init];
    }
    return self;
}

- (void)setStats:(NSArray *)stats
{
//    for (RTCLegacyStatsReport *report in stats)
//    {
//        [mStatsBuilder parseStatsReport:report];
//    }
//    mStatsLabel.text = mStatsBuilder.statsString;
}

- (void)layoutSubviews
{
    mStatsLabel.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [mStatsLabel sizeThatFits:size];
}



@end
