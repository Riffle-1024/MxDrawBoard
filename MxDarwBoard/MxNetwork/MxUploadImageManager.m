//
//  MxUploadImageManager.m
//  MxDarwBoard
//
//  Created by liuyalu on 2022/2/23.
//

#import "MxUploadImageManager.h"
#import "AFNetworking.h"

#define knewLine @"\r\n"
#define boundary @"--------------------------588071440901578518229218"

@interface MxUploadImageManager()<NSURLSessionDelegate>

@end

@implementation MxUploadImageManager


+(instancetype)shareInstance{
    static MxUploadImageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MxUploadImageManager alloc] init];
    });
    
    return instance;
}

+(void)uploadImageWithUrl:(NSString *)url ImageData:(NSData *)imageData Completion:(void (^)(NSError *error, BOOL isSuccess))completionHandle{

    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:[MxUploadImageManager shareInstance] delegateQueue:[NSOperationQueue mainQueue]];


//    [request setValue:@"2022022316191000" forHTTPHeaderField:@"awe_image"];

    //7、创建上传任务 上传的数据来自getData方法
       NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:[[MxUploadImageManager shareInstance] getBodyDataWithImageData:imageData] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error) {
               completionHandle(error,NO);
           }else{
               NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                 DLog(@"jsonDict:%@",jsonDict);
               completionHandle(nil,YES);
           }
       }];
       //8、执行上传任务
       [task resume];
}





-(NSData *)getBodyDataWithImageData:(NSData *)imageData{

    NSMutableString *bodyString = [[NSMutableString alloc] init];
//    [bodyString appendFormat:@"--%@\r\n",boundary];
//    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"FileName\"\r\n"];
//    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
//    [bodyString appendFormat:@"%@.png\r\n",@"TestImage01"];
    
    //PostID
//    [bodyString appendFormat:@"--%@\r\n",boundry];
//    [bodyString appendFormat:@"Content-Disposition: form-data; name=\"PostID\"\r\n"];
//    [bodyString appendFormat:@"Content-Type: text/plain; charset=\"utf-8\"\r\n\r\n"];
//    [bodyString appendFormat:@"%@\r\n",self.uuID];
    
    //pic
//    [bodyString appendFormat:@"%@\r\n",boundary];
    [bodyString appendFormat:@"Content-Disposition: form-data; awe_image="];
//    [bodyString appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
    //[bodyString appendFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
    
    //string --> data
    NSMutableData *bodyData = [NSMutableData data];
    //前面的bodyString, 其他参数
    [bodyData appendData:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    //图片数据
    [bodyData appendData:imageData];
   
    //结束的分隔线
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
    //拼接到bodyData最后面
    [bodyData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}


+ (void)POST:(NSString *)URL parameters:(NSDictionary *)dic FileData:(NSData *)fileData fileName:(NSString *)fileName success:(httpRequestSuccess)success failure:(httpRequestFailed)failure{


    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
        //上传超时设置
        manager.requestSerializer.timeoutInterval = 10.0;
        //重点注意：para中的data的key值要和下面文件流的name一致，不然服务器会收到字符串而不是文件。
        NSDictionary *para = @{@"awe_image":fileData};
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];

    [manager POST:URL parameters:para headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"awe_image" fileName:[NSString stringWithFormat:@"%@.png",fileName] mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            id json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            success(responseObject);
              DLog(@"responseObject:%@",responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(error);
            DLog(@"error:%@",error);
        }];
}
#pragma mark - NSURLSessionDelegate -

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{

    //设置进度条
}
@end
