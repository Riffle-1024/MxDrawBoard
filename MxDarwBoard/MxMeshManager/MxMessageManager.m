//
//  MxMessageManager.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/7/7.
//

#import "MxMessageManager.h"
#import "MxMeshManager.h"
#import "MxDrawBoardManager.h"
#import "AppInfo.h"
#import "MxTimer.h"

typedef void(^SendMessageCallBack)(LocationModel *locationModel);

@interface MxMessageManager()

@property(nonatomic,copy) NSMutableArray <LocationModel *>*messageArray;

@property(nonatomic,copy) NSString * uuid;

@property(nonatomic,assign) BOOL isSending;//是否正在发送消息

@property(nonatomic,strong) NSLock *messageLock;//保证数据安全进行加锁

@property (nonatomic,strong) MxTimer *timer;

@property (nonatomic,strong) LocationModel *currentModel;

@property (nonatomic,assign) BOOL meshIsConnect;

@property (nonatomic,copy) NSMutableDictionary *messageArrayKey;//所有代发数据的key值，为设备的location

@property (nonatomic,copy) SendMessageCallBack sendCallBack;

@property (nonatomic,copy) NSString *cmdType;

@end

static MxMessageManager *instance = nil;

@implementation MxMessageManager

-(NSString *)cmdType{
    if (!_cmdType) {
        _cmdType = @"2401";
    }
    return _cmdType;
}

+(void)addLocationModel:(LocationModel *)model{
    [[MxMessageManager shareInstance] addLocationModel:model];
}

-(NSMutableDictionary *)messageArrayKey{
    if (_messageArrayKey) {
        _messageArrayKey = [NSMutableDictionary dictionary];
    }
    return _messageArrayKey;
}

-(NSMutableArray <LocationModel *>*)messageArray{
    if (!_messageArray) {
        _messageArray = [[NSMutableArray alloc] init];
    }
    
    return _messageArray;
}

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MxMessageManager alloc] init];
    });
    return instance;
}



-(void)addLocationModel:(LocationModel *)model{
    self.cmdType = @"2401";
    NSString * modelKey = [NSString stringWithFormat:@"%d",model.location];
    if ([self.messageArrayKey valueForKey:modelKey]) {
        [self deleteMessageWithModel:model];//先删除旧消息
    }
    [self.messageArray addObject:model];//如果本地没有待发送的消息，直接添加到本地，并开始发送消息
    
//    if (self.messageArray.count) {//已经有数据要先判断本地是否有同一位置的model消息还未发送，如果有就将之前的model删除掉，最终发送最新的model消息
//
//    }else{
        
//    }
    //如果mesh还没有连接，先保存数据，等待连接成功后再发送消息
    if (self.meshIsConnect) {
        if (!self.isSending) {
            [self startSendMessage];
        }
    }
}


//添加某条消息
-(void)addMessageWithModel:(LocationModel *)model{
    [self.messageLock lock];
    [self.messageArray addObject:model];
    [self.messageArrayKey setValue:@"1" forKey:[NSString stringWithFormat:@"%d",model.location]];
    DLog(@"addMessge：%d",model.location);
    [self.messageLock unlock];
}

//删除某条消息
-(void)deleteMessageWithModel:(LocationModel *)model{
    [self.messageLock lock];
    for (LocationModel *locationModel in self.messageArray) {
        if (locationModel.location == model.location) {
            DLog(@"deleteMessage：%d",model.location);
            [self.messageArrayKey removeObjectForKey:[NSString stringWithFormat:@"%d",locationModel.location]];
            [self.messageArray removeObject:locationModel];
            break;
        }
    }
    [self.messageLock unlock];
}

//删除已经发送过的消息
-(void)deleteCurrenModel:(LocationModel *)model{
    [self.messageLock lock];
    if ([self.messageArray containsObject:model]) {
        DLog(@"deleteHasSendMessage：%d",model.location);
        [self.messageArray removeObject:model];
    }
    [self.messageLock unlock];
}

-(void)startSendMessage{
    self.isSending = YES;
    DLog(@"start send message");
    if (!self.timer) {
        self.timer = [[MxTimer alloc] initWithTimeInterval:TimeInterval andWaitTime:0 eventHandler:^{
            
            if (self.messageArray.count) {
                LocationModel *model = [self.messageArray objectAtIndex:0];
                DLog(@"send yuzhise message：%d",model.location);
                self.currentModel = model;
                [MxMessageManager sendMessageWithLocalModel:model];
                [self deleteCurrenModel:self.currentModel];
            }else{
                DLog(@"message send finish，stop send");
                self.isSending = NO;
                [self.timer pauseTimer];
            }
        }];
    }else{
        DLog(@"jixu  sendMessage");
        [self.timer resumeTimer];
    }
    
}


-(void)sendMessageWithLocationModel:(LocationModel *)model{
    NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:model.location + 1];
    NSString *cmdStr = [NSString stringWithFormat:@"2301%@",model.hsvColor];
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    [MxMeshManager sendMeshMessageWithOpCode:@"12" uuid:uuid elementIndex:0 Tid:@"" message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
        
    }];
}

+(void)sendMessageWithLocalModel:(LocationModel *)locationModel{
    
    if (locationModel.isOpen) {
        NSString * cmd = [NSString stringWithFormat:@"%@%@",[MxMessageManager shareInstance].cmdType,locationModel.hsvColor];
        
        NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:locationModel.location + 1];
        if (![MxMessageManager shareInstance].uuid) {
            [MxMessageManager shareInstance].uuid = uuid;
        }
        
        [MxMessageManager sendMeshMessage:cmd UUID:uuid];
        if ([MxMessageManager shareInstance].sendCallBack && [[MxMessageManager shareInstance].cmdType isEqualToString:@"2301"]) {
            [MxMessageManager shareInstance].sendCallBack(locationModel);
        }
    }else{
        [MxMessageManager cleanLightWithLocalModel:locationModel];
    }

    
}

+(void)cleanLightWithLocalModel:(LocationModel *)locationModel{
    NSString *cmdStr = @"250100";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:locationModel.location + 1];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];;
    [MxMeshManager sendMeshMessageWithOpCode:@"12" uuid:uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {

    }];
}

+ (void)sendMeshMessage:(NSString *)message UUID:(NSString *)uuid{
    DLog(@"send yuzhise message：%@,uuid:%@",message,uuid);
    NSString *msg = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary * _Nullable result) {
//        NSString *message = result[@"message"];
        DLog(@"message result:%@",result);
    }];
}

//一键投屏
+(void)showScreen{
    DLog(@"send yijiantouping");
    NSString *cmdStr = @"250101";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];;
//    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:[MxMessageManager shareInstance].uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
//
//    }];
    [MxMeshManager sendGroupMessageWithAddress:@"C100" opCode:@"12" uuid:nil elementIndex:0 message:msg networkKey:[AppInfo sharedInstance].netWorkKey repeatNum:1];
    
}

//一键清屏
+(void)cleanScreen{
    [[MxMessageManager shareInstance] deletAllMessage];
    NSString *cmdStr = @"250100";
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];
    [MxMeshManager sendGroupMessageWithAddress:@"C100" opCode:@"12" uuid:nil elementIndex:0 message:msg networkKey:[AppInfo sharedInstance].netWorkKey repeatNum:1];
}
+(void)setMeshNetWorkIsConnect:(BOOL)isConnect{
    [MxMessageManager shareInstance].meshIsConnect = isConnect;
}

-(void)setMeshIsConnect:(BOOL)meshIsConnect{
    _meshIsConnect = meshIsConnect;
    if (meshIsConnect && self.messageArray.count) {
        [[MxMessageManager shareInstance] startSendMessage];
    }
}

+(NSInteger)getWaitSendMessageCount{
    return [MxMessageManager shareInstance].messageArray.count;
}

+(void)sendDebugMessageWithLocalModel:(LocationModel *)locationModel{
    NSString * cmd = [NSString stringWithFormat:@"2301%@",locationModel.hsvColor];
    
    NSString *uuid = [MxDrawBoardManager getDeviceUUIDWithLocation:locationModel.location + 1];
    
    [MxMessageManager sendMeshMessage:cmd UUID:uuid];
}

+(void)sendDrawAllLightMessagezWithColro:(UIColor *)color Complete:(void(^)(LocationModel *locationModel))complete{
    [MxMessageManager shareInstance].sendCallBack = complete;
    [[MxMessageManager shareInstance].messageArray removeAllObjects];
    [MxMessageManager shareInstance].cmdType = @"2301";
    for (int i = 0; i < [MxDrawBoardManager shareInstance].pointList.count; i++) {
        UIColor *paintColor = color;
        LocationModel *locationModel = [[LocationModel alloc] initWithLocation:i Color:paintColor IsOpen:YES];
        [[MxMessageManager shareInstance].messageArray addObject:locationModel];
    }
    if ([MxMessageManager shareInstance].meshIsConnect && [MxMessageManager shareInstance].messageArray.count) {
        [[MxMessageManager shareInstance] startSendMessage];
    }
    
}

+(void)sendGroupMessage:(NSString*)hsvColor{
    DLog(@"send qunzutouping");
    
    NSString *cmdStr = [NSString stringWithFormat:@"2301%@",hsvColor];
    NSString *msg = [cmdStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    msg = [msg stringByReplacingOccurrencesOfString:@"" withString:@" "];;
//    [MxMeshManager sendMeshMessageWithOpCode:@"11" uuid:[MxMessageManager shareInstance].uuid elementIndex:0 Tid:nil message:msg retryCount:1 timeout:1 isHoldCallback:NO networkKey:nil callback:^(NSDictionary<NSString *,id> * _Nonnull resultObject) {
//
//    }];
    [MxMeshManager sendGroupMessageWithAddress:@"C100" opCode:@"12" uuid:nil elementIndex:0 message:msg networkKey:[AppInfo sharedInstance].netWorkKey repeatNum:1];
}

+(void)cleanAllMessage{
    [[MxMessageManager shareInstance] deletAllMessage];
}

-(void)deletAllMessage{
    [self.messageLock lock];
    [self.messageArray removeAllObjects];
    [self.messageLock unlock];
}
@end
