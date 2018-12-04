//
//  ViewController.h
//  J140_autoMate softWare
//
//  Created by Eason on 2018/11/19.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (nonatomic,copy) NSString * SN1;
@property (nonatomic,copy) NSString * SN2;
@property (nonatomic,copy) NSString * SN3;
@property (nonatomic,copy) NSString * SN4;
@property (weak) IBOutlet NSTextField *tfPASS;
@property (weak) IBOutlet NSTextField *tfFAIL;




@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSTextField *ipTf;
@property (weak) IBOutlet NSTextField *portTf;
@property (nonatomic,assign) int sumaryPass;
@property (nonatomic,assign) int sumaryFail;

@property (nonatomic,copy) NSString * Log;




@end

