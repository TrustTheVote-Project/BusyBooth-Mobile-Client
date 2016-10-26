//
//  SmallWaitTime.h
//  BusyBooth
//
//  Created by Hunter Lightman on 3/9/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "WaitTimeTableViewCell.h"

@interface SmallWaitTime : WaitTimeTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier time:(int)time wait:(int)wait;

@end
