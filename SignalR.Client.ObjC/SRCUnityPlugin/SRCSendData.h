/**
 * Data model for de/serialization that matches Unity C# SRCHubConnection.SendData.
 */
@interface SRCSendData : NSObject

@property NSString *RequestId;
@property NSString *Response;

@end