//
//  CustomCollectionViewCell.h
//  Renstagram
//
//  Created by Ivan Ruiz Monjo on 19/08/14.
//  Copyright (c) 2014 Rens Gang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

@end
