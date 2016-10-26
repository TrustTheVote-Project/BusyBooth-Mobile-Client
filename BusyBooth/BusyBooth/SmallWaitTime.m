//
//  SmallWaitTime.m
//  BusyBooth
//
//  Created by Hunter Lightman on 3/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "SmallWaitTime.h"

@interface SmallWaitTime ()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *minutesLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *gaugeView;

@end

@implementation SmallWaitTime

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier time:(int)time wait:(int)wait {
    self = [super initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:reuseIdentifier
                           time:time
                           wait:wait];

    if (self) {
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, 300, 30)];
        self.descriptionLabel.textColor = [self foregroundColor];
        self.descriptionLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        [self addSubview:self.descriptionLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 51, 3, 50, 30)];
        self.timeLabel.textColor = [self foregroundColor];
        self.timeLabel.font = [UIFont fontWithName:@"Arial" size:30.0f];
        [self addSubview:self.timeLabel];
        
        self.minutesLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 48.5, 18, 50, 30)];
        self.minutesLabel.text = @"Minutes";
        self.minutesLabel.textColor = [self foregroundColor];
        self.minutesLabel.font = [UIFont fontWithName:@"Arial" size:8.0f];
        [self addSubview:self.minutesLabel];
        
        CGFloat lineX = self.frame.size.width - 70;
        CGFloat lineY = 1;
        CGFloat lineWidth = 1;
        CGFloat lineHeight = self.frame.size.height - 4;
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(lineX, lineY, lineWidth, lineHeight)];
        self.lineView.backgroundColor = [self foregroundColor];
        [self addSubview:self.lineView];
        
        self.gaugeView = [[UIImageView alloc] initWithImage:[self gaugeImage]];
        self.gaugeView.frame = CGRectOffset(self.gaugeView.frame, (self.frame.size.width - self.gaugeView.frame.size.width)/2, 5);
        //[self addSubview:self.gaugeView];
        
        NSString *time_string;
        if(time == 0) {
            time_string = @"12:30 AM";
        } else if(time < 12) {
            time_string = [NSString stringWithFormat:@"%d:30 AM", time];
        } else if(time == 12) {
            time_string = @"12:30 PM";
        } else {
            time_string = [NSString stringWithFormat:@"%d:30 PM", time % 12];
        }
        self.descriptionLabel.text = time_string;
        
        NSString *desc_string;
        if (self.wait == -1) {
            desc_string = @"n/a";
            self.timeLabel.font = [UIFont fontWithName:@"Arial" size:24.0f];
        } else {
            desc_string = [NSString stringWithFormat:@"%d", self.wait];
        }
        self.timeLabel.text = desc_string;
    }
    
    return self;
}

@end
