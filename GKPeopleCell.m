//
//  GKPeopleCell.m
//  GKContactExchange
//
//  Created by georgkitz on 8/30/12.
//  Copyright (c) 2012 Georg Kitz. All rights reserved.
//

#import "GKPeopleCell.h"

@interface GKPeopleCell ()

@end

@implementation GKPeopleCell

- (void)setPreselectedCell:(BOOL)preselectedCell
{
    _preselectedCell = preselectedCell;
    self.textLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor blackColor];
    self.imageView.image = preselectedCell ? [UIImage imageNamed:@"wippi"] : nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.font = [UIFont boldSystemFontOfSize:20];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:20];
        self.detailTextLabel.textColor = [UIColor blackColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    
    CGFloat textWidth = CGRectGetWidth(self.textLabel.frame);
    CGFloat maxWidth = CGRectGetWidth(self.contentView.frame) - 20;
    CGFloat width = textWidth < maxWidth ? textWidth : maxWidth;
    
    CGFloat restWidht = 0;
    if (_preselectedCell) {
        restWidht = textWidth + 10 + 16 + 5 < maxWidth ? maxWidth - textWidth - 10 - 16 - 5: 0;
    } else {
        restWidht = textWidth + 10  < maxWidth ? maxWidth - textWidth - 10 : 0;
    }
    
    self.textLabel.frame = CGRectMake(10, 0, width, 43);
    self.detailTextLabel.frame = CGRectMake(width + 20, 0, restWidht, 43);
    self.imageView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 10 - self.imageView.frame.size.width, 14, self.imageView.frame.size.width, self.imageView.frame.size.height);
}

@end
