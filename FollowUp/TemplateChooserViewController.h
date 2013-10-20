//
//  TemplateChooserViewController.h
//  FollowUp
//
//  Created by Brian Soule on 10/19/13.
//  Copyright (c) 2013 Soule Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCaptureViewController.h"

@interface TemplateChooserViewController : UITableViewController
{
    id __unsafe_unretained delegate;
}

@property (unsafe_unretained) CardCaptureViewController *delegate;
@property (retain) NSMutableArray *templates;

@end
