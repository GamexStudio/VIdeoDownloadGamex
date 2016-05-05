//
//  CustomCell.m
//  FlipSample
//
//  Created by TheTiger on 05/05/16.
//  Copyright © 2016 TheTiger. All rights reserved.
//

#import "CustomCell.h"

@interface CustomCell () <NSURLSessionDownloadDelegate>

@end

@implementation CustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.progressView setProgress:0 animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}

@end
