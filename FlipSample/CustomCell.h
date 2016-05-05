//
//  CustomCell.h
//  FlipSample
//
//  Created by TheTiger on 05/05/16.
//  Copyright © 2016 TheTiger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *button;
@property (nonatomic, weak) IBOutlet UILabel  *lblProgress;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end
