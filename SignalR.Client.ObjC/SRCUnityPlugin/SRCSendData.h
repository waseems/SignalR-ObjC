/**
 * Data model for de/serialization that matches Unity C# SRCHubConnection.SendData.
 */
@interface SRCSendData : NSObject

@property NSString *RequestId;
@property NSString *Response;

- (NSDictionary *) getDict;

@end

@implementation SRCSendData

- (NSDictionary *) getDict
{
    NSDictionary *dict = @{@"RequestId":self.RequestId, @"Response":self.Response};
    return dict;
}

@end