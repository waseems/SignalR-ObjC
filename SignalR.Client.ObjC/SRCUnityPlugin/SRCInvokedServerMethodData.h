/**
 * Data model for de/serialization that matches Unity C# SRCHubProxy.InvokedServerMethodData.
 */
@interface SRCInvokedServerMethodData : NSObject

@property NSString *RequestId;
@property NSString *Data;

- (NSDictionary *) getDict;

@end

@implementation SRCInvokedServerMethodData

- (NSDictionary *) getDict
{
    NSDictionary *dict = @{@"RequestId":self.RequestId, @"Data":self.Data};
    return dict;
}

@end