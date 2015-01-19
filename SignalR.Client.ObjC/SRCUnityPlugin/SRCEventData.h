/**
 * Data model for de/serialization that matches Unity C# SRCHubProxy.EventData.
 */
@interface SRCEventData : NSObject

@property NSString *EventName;
@property NSString *Data;

@end