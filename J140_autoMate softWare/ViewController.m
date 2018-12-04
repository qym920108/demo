//
//  ViewController.m
//  J140_autoMate softWare
//
//  Created by Eason on 2018/11/19.
//  Copyright © 2018年 Eason Qian. All rights reserved.
//

#import "ViewController.h"
#import "TCPManager.h"

#define PATH @"/vault/AUTO"
#define CMDPath @"/vault/AUTO/CMD.txt"
#define STATUSPATH @"/vault/AUTO/Status.txt"
#define SNPATH @"/vault/AUTO/sfTmpSN.txt"


@implementation ViewController

{
    TCPManager * _socket;

    NSString * _CMDStr;
    NSFileManager * _fileManager;
    NSTimer * _s1TImer;
    NSTimer * _s2TImer;
    NSTimer * _s3TImer;
    NSTimer * _s4TImer;
    
    NSString * _s1;
    NSString * _s2;
    NSString * _s3;
    NSString * _s4;
    
    NSFileHandle * _logHandle;
    

}





- (void)viewDidLoad {
    [super viewDidLoad];

    
    _fileManager = [NSFileManager defaultManager];
    
    self.sumaryFail = 0;
    self.sumaryPass = 0;
    
    self.Log = [[NSString alloc]init];
    
    
    NSString * Vstr = [NSString stringWithFormat:@"AutoMate - Client - V%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [NSApplication sharedApplication].mainWindow.title = Vstr;
    
    
    //NSLog(@"date:%@",[self getCurrentTime]);
    
    
    
    // Do any additional setup after loading the view.
}







-(NSString *)getCurruntTime{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
    
    NSDate * now = [NSDate date];
    NSString * dateStr = [formatter stringFromDate:now];
    
    return dateStr;
    
}









-(void)createTimer{
    _s1TImer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readS1Status) userInfo:nil repeats:YES];
    _s1TImer.fireDate = [NSDate distantFuture];
    
    _s2TImer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readS2Status) userInfo:nil repeats:YES];
    _s2TImer.fireDate = [NSDate distantFuture];
    
    _s3TImer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readS3Status) userInfo:nil repeats:YES];
    _s3TImer.fireDate = [NSDate distantFuture];
    
    _s4TImer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(readS4Status) userInfo:nil repeats:YES];
    _s4TImer.fireDate = [NSDate distantFuture];
}



-(void)listenCMD{
    __weak typeof(self) weakSelf = self;
    _CMDStr = [self readFile];
    
    
    
    [self logInfo:[NSString stringWithFormat:@"CMD :%@",_CMDStr]];
    [self FXLOG:[NSString stringWithFormat:@"CMD :%@",_CMDStr] info:@"InFo"];
    
    if ([_CMDStr containsString:@"OPEN"]) {
        [_socket sendCommandData:@"CtrlDrawer:01;"];
        [self logCMD:@"CtrlDrawer:01;" tx:@"TX"];
        [self FXLOG:@"CtrlDrawer:01;" info:@"TX"];
        _socket.readDataBlock = ^(NSString *str) {
            [weakSelf logCMD:str tx:@"RX"];
            [weakSelf FXLOG:str info:@"RX"];
            
            if ([str containsString:@"CtrlDrawer:01"]) {
                [weakSelf updateStatusFile:@"OPEN  "];
                [weakSelf removeFile:CMDPath];
                [weakSelf logInfo:@"Drawer has been Opened"];
                [weakSelf FXLOG:@"Drawer has been Opened" info:@"InFo"];
            }
            else{
                [weakSelf updateStatusFile:@"UNKNOW"];
                [weakSelf logInfo:@"Drawer Status UNKNOW"];
                [weakSelf FXLOG:@"Drawer Status UNKNOW" info:@"InFo"];

                
            }
        };
    }
    else if ([_CMDStr containsString:@"CLOSE"])
    {
        [_socket sendCommandData:@"CtrlDrawer:02;"];
        [self logCMD:@"CtrlDrawer:02" tx:@"TX"];
        [self FXLOG:@"CtrlDrawer:02" info:@"TX"];
        _socket.readDataBlock = ^(NSString *str) {
            [weakSelf logCMD:str tx:@"RX"];
            [weakSelf FXLOG:str info:@"RX"];
            if ([str containsString:@"CtrlDrawer:09"]) {
                [weakSelf updateStatusFile:@"CLOSE  "];
                [weakSelf removeFile:CMDPath];
                [weakSelf logInfo:@"Drawer has been closed"];
                [weakSelf FXLOG:@"Drawer has been closed" info:@"InFo"];
            }
            else{
                [weakSelf updateStatusFile:@"UNKNOW"];
                [weakSelf logInfo:@"Drawer status unknow"];
                 [weakSelf FXLOG:@"Drawer Status UNKNOW" info:@"InFo"];

            }
        };
    }
}


-(void)readS1Status{
    if ([self isCMDFile]) {
        [self listenCMD];
    }
    else{
        if ([self isTmpFile]) {
            if ([self readSNFile]) {
                _s1 = [_socket readTestLEDStatus:self.SN1 slot:1];
                [self logInfo:_s1];
                [self FXLOG:_s1 info:@"InFo"];
                if ([_s1 containsString:@"PASS"] || [_s1 containsString:@"FAIL"] || [_s1 containsString:@"SKIP"]) {
                    if ([_s1 containsString:@"PASS"]) {
                        self.sumaryPass++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfPASS.stringValue = [NSString stringWithFormat:@"%d",self.sumaryPass];
                        });
                    }
                    else if ([_s1 containsString:@"FAIL"]){
                        self.sumaryFail++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfFAIL.stringValue = [NSString stringWithFormat:@"%d",self.sumaryFail];
                        });
                    }
                    _s1TImer.fireDate = [NSDate distantFuture];
                    _s2TImer.fireDate = [NSDate distantPast];
                }
                
            }
            else{
                //NSLog(@"SN Length not match");
                [self logInfo:@"SN Length not match"];
                [self FXLOG:@"SN Length not match" info:@"InFo"];
            }
        }
    }
    
}

-(void)readS2Status{
    if ([self isCMDFile]) {
        [self listenCMD];
    }
    else{
        if ([self isTmpFile]) {
            if ([self readSNFile]) {
                _s2 = [_socket readTestLEDStatus:self.SN2 slot:2];
                [self logInfo:_s2];
                [self FXLOG:_s2 info:@"InFo"];
                

                if ([_s2 containsString:@"PASS"] || [_s2 containsString:@"FAIL"] || [_s2 containsString:@"SKIP"]) {
                    if ([_s3 containsString:@"PASS"]) {
                        self.sumaryPass++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfPASS.stringValue = [NSString stringWithFormat:@"%d",self.sumaryPass];
                        });
                    }
                    else if ([_s3 containsString:@"FAIL"]){
                        self.sumaryFail++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfFAIL.stringValue = [NSString stringWithFormat:@"%d",self.sumaryFail];
                        });
                    }
                    _s2TImer.fireDate = [NSDate distantFuture];
                    _s3TImer.fireDate = [NSDate distantPast];
                }
                
            }
            else{
                [self logInfo:@"SN Length not match"];
                [self FXLOG:@"SN Length not match" info:@"InFo"];
            }
        }
    }
}

-(void)readS3Status{
    if ([self isCMDFile]) {
        [self listenCMD];
    }
    else{
        if ([self isTmpFile]) {
            if ([self readSNFile]) {
                _s3 = [_socket readTestLEDStatus:self.SN3 slot:3];
                [self logInfo:_s3];
                [self FXLOG:_s3 info:@"InFo"];
                if ([_s3 containsString:@"PASS"] || [_s3 containsString:@"FAIL"] || [_s3 containsString:@"SKIP"]) {
                    if ([_s3 containsString:@"PASS"]) {
                        self.sumaryPass++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfPASS.stringValue = [NSString stringWithFormat:@"%d",self.sumaryPass];
                        });
                    }
                    else if ([_s3 containsString:@"FAIL"]){
                        self.sumaryFail++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfFAIL.stringValue = [NSString stringWithFormat:@"%d",self.sumaryFail];
                        });
                    }
                    _s3TImer.fireDate = [NSDate distantFuture];
                    _s4TImer.fireDate = [NSDate distantPast];
                }
                
            }
            else{
                [self logInfo:@"SN Length not match"];
                [self FXLOG:@"SN Length not match" info:@"InFo"];
            }
        }
    }
}

-(void)readS4Status{
    if ([self isCMDFile]) {
        [self listenCMD];
    }
    else{
        if ([self isTmpFile]) {
            if ([self readSNFile]) {
                _s4 = [_socket readTestLEDStatus:self.SN4 slot:4];
                [self logInfo:_s4];
                [self FXLOG:_s4 info:@"InFo"];

                if ([_s4 containsString:@"PASS"] || [_s4 containsString:@"FAIL"] || [_s4 containsString:@"SKIP"]) {
                    if ([_s4 containsString:@"PASS"]) {
                        self.sumaryPass++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfPASS.stringValue = [NSString stringWithFormat:@"%d",self.sumaryPass];
                        });
                    }
                    else if ([_s4 containsString:@"FAIL"]){
                        self.sumaryFail++;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.tfFAIL.stringValue = [NSString stringWithFormat:@"%d",self.sumaryFail];
                        });
                    }
                    _s4TImer.fireDate = [NSDate distantFuture];
                    _s1TImer.fireDate = [NSDate distantPast];
                }
                
            }
            else{
                [self logInfo:@"SN Length not match"];
                [self FXLOG:@"SN Length not match" info:@"InFo"];
            }
        }
    }
}








-(BOOL)readSNFile{
    NSFileHandle * fh = [NSFileHandle fileHandleForReadingAtPath:SNPATH];
    NSData * data = [fh readDataToEndOfFile];
    NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray * arr = [str componentsSeparatedByString:@"\n"];
    //NSLog(@"arr:%@",arr);
    
    if (arr.count != 4) {
        return NO;
    }
    else{
        self.SN1 = arr[0];
        self.SN2 = arr[1];
        self.SN3 = arr[2];
        self.SN4 = arr[3];
        //NSLog(@"SN1:%@,SN2:%@,SN3:%@,SN4:%@",self.SN1,self.SN2,self.SN3,self.SN4);
        [self logInfo:[NSString stringWithFormat:@"SN1:%@,SN2:%@,SN3:%@,SN4:%@",self.SN1,self.SN2,self.SN3,self.SN4]];
        [self FXLOG:[NSString stringWithFormat:@"SN1:%@,SN2:%@,SN3:%@,SN4:%@",self.SN1,self.SN2,self.SN3,self.SN4] info:@"InFo"];
        [self removeFile:SNPATH];
        return YES;
    }
    
}




-(NSString *)readFile{
    NSFileHandle * fh = [NSFileHandle fileHandleForUpdatingAtPath:CMDPath];
    NSData * data = [fh readDataToEndOfFile];
    NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

-(void)removeFile:(NSString *)path{
    NSError * error;
    BOOL ret = [_fileManager removeItemAtPath:path error:&error];
    if (ret) {
        //NSLog(@"File has been Removed");
        [self logInfo:@"snTmpFile has been removed"];
        [self FXLOG:@"snTmpFile has been removed" info:@"InFo"];
    }
    else{
        //NSLog(@"error:%@",error);
        [self logInfo:[NSString stringWithFormat:@"error:%@",error]];
        [self FXLOG:@"ERROR" info:@"ERR"];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


-(BOOL)isCMDFile{
    
    
    BOOL isExist = [_fileManager fileExistsAtPath:CMDPath];
    if (isExist) {
        //NSLog(@"CMD already Exist");
        [self logInfo:@"CMD already Exist"];
        [self FXLOG:@"CMD already Exist" info:@"InFo"];
        return YES;
    }
    else{
        //NSLog(@"CMD NOT Exist");
        [self logInfo:@"CMD NOT Exist"];
        [self FXLOG:@"CMD NOT Exist" info:@"InFo"];

        return NO;
    }
}

-(BOOL)isTmpFile{
    BOOL isExist = [_fileManager fileExistsAtPath:SNPATH];
    if (isExist) {
        //NSLog(@"File already Exist");
        [self logInfo:@"sfTmpFile Exist"];
        [self FXLOG:@"sfTmpFile Exist" info:@"InFo"];
        return YES;
    }
    else{
        //NSLog(@"File NOT Exist");
        [self logInfo:@"sfTmpFile NOT Exist"];
        [self FXLOG:@"sfTmpFile NOT Exist" info:@"InFo"];
       return NO;
    }
}

-(void)isPath{
    BOOL b;
    BOOL isPath = [_fileManager fileExistsAtPath:PATH isDirectory:&b];
    
    
    if (isPath) {
        //NSLog(@"exist");
        [self logInfo:@"PATH EXIST"];
        [self FXLOG:@"PATH EXIST" info:@"InFo"];
    }
    else{
        NSError * error;
        BOOL ret = [_fileManager createDirectoryAtPath:PATH withIntermediateDirectories:YES attributes:nil error:&error];
        if (ret) {
//            NSLog(@"Create OK");
            [self logInfo:@"PATH Create OK"];
            [self FXLOG:@"PATH Create OK" info:@"InFo"];

        }
        else{
            //NSLog(@"Create NO");
            [self logInfo:@"PATH Create Fail"];
            [self FXLOG:@"PATH Create Fail" info:@"InFo"];

        }
    }

}

-(void)updateStatusFile:(NSString *)msg{
    [self isPath];
    BOOL isExist = [_fileManager fileExistsAtPath:STATUSPATH];
    if (!isExist) {
        [_fileManager createFileAtPath:STATUSPATH contents:nil attributes:nil];
    }
    NSFileHandle * fh = [NSFileHandle fileHandleForWritingAtPath:STATUSPATH];
    NSData * data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [fh writeData:data];
}




- (IBAction)startAutomate:(id)sender {
    [self isPath];
    
    [self createTimer];
    
    __weak typeof(self) weakSelf = self;
    
    self.ipTf.enabled = NO;
    self.portTf.enabled = NO;
    
    _socket = [TCPManager shareInstance];
    [_socket openSocketWithPort:self.portTf.stringValue host:self.ipTf.stringValue reply:^(NSString *reply) {
        [weakSelf logInfo:reply];
    }];
    
    
    
    _s1TImer.fireDate = [NSDate distantPast];
    
    
    
    
    
    
    
    
    
}
- (IBAction)stopAutomate:(id)sender {
    self.ipTf.enabled = YES;
    self.portTf.enabled = YES;
    
    _s1TImer.fireDate = [NSDate distantFuture];
    
    [_socket closeSocket];
    
    [self timerRelease];
}



- (NSString *)getCurrentTime{
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy.MM.dd.HH.mm.ss.SSS"];
    [formatter setTimeZone:nil];
    NSString * timeStamp =[formatter stringFromDate:[NSDate date]];
    return timeStamp;
}

-(void)logInfo:(NSString *)info{
    NSString * str = [NSString stringWithFormat:@"[%@] [info] ==> %@ \n",[self getCurrentTime],info];
   self.Log = [self.Log stringByAppendingString:str];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.string = self.Log;
    });
}

-(void)logCMD:(NSString *)cmd tx:(NSString *)txRx{
    NSString * str = [NSString stringWithFormat:@"[%@] [%@] ==> %@ \n",[self getCurrentTime],txRx,cmd];
    self.Log = [self.Log stringByAppendingString:str];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.string = self.Log;
    });
}



-(void)timerRelease{
    [_s1TImer invalidate];
    _s1TImer = nil;
    
    [_s2TImer invalidate];
    _s2TImer = nil;
    
    [_s3TImer invalidate];
    _s3TImer = nil;
    
    [_s4TImer invalidate];
    _s4TImer = nil;
}


-(void)FXLOG:(NSString *)msg info:(NSString *)Info{
    [self isPath];
    
    NSString * filePath = [NSString stringWithFormat:@"%@/autoMateLog.txt",PATH];
    
    BOOL isExist = [_fileManager fileExistsAtPath:filePath];
    if (!isExist) {
        [_fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    _logHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    NSString * str = [NSString stringWithFormat:@"[%@][%@] %@\r\n",[self getCurrentTime],Info,msg];
    
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [_logHandle writeData:data];
    
}


















@end
