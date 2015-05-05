//
//  DetailViewController.h
//  TBD3
//
//  Created by Christine Dierk on 5/5/15.
//  Copyright (c) 2015 Christine Dierk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

