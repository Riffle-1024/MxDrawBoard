//
//  MxUploadImageManager.h
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import <Foundation/Foundation.h>

typedef void(^httpRequestSuccess) (NSDictionary*_Nullable);

typedef void(^httpRequestFailed) (NSError*_Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface MxUploadImageManager : NSObject

+(void)uploadImageWithUrl:(NSString *)url ImageData:(NSData *)imageData Completion:(void (^)(NSError *error, BOOL isSuccess))completionHandle;

+ (void)POST:(NSString *)URL parameters:(NSDictionary *)dic FileData:(NSData *)fileData fileName:(NSString *)fileName success:(httpRequestSuccess)success failure:(httpRequestFailed)failure;
@end

NS_ASSUME_NONNULL_END
