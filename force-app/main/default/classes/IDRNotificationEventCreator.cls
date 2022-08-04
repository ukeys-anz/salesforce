/**
 * @author Adam Smith
 * @since 20220725
 * @description Abstract Base Class for creating IDR_Notification_Events
 */
public with sharing abstract class IDRNotificationEventCreator extends PlatformEventCreator {
  /**
   * @description creates IDR NotificationEvents
   * @return List<IDR_Notification_Event__e>
   */
  protected abstract List<IDR_Notification_Event__e> createEvents();

  protected override SObject createBaseEvent(SObject targetsObject) {
    return (SObject) createBaseEvent(targetsObject);
  }

  /**
   * @description creates a base IDR_Notification_Event__e record
   * @param targetsObject target Object
   * @return new instance of IDR_Notification_Event__e based on the target object.
   */
  @testVisible
  protected IDR_Notification_Event__e createBaseIDRNotificationEvent(
    SObject targetsObject
  ) {
    IDR_Notification_Event__e notification = new IDR_Notification_Event__e();
    notification.MessageID__c =
      '' +
      targetsObject.Id +
      Datetime.now().millisecond();
    notification.Record_Id__c = targetsObject.Id;
    return notification;
  }

  /**
   * @description creates a single IDR_Notification_Event__e
   * @param targetsObject base object to create the Event
   * @param dataMap information about the base object on other objects
   * @param platformEvent base PlatformEvent
   * @return IDR_Notification_Event__e
   */
  @testVisible
  protected abstract IDR_Notification_Event__e newPlatformEvent(
    SObject targetsObject,
    Map<Id, SObject> dataMap,
    IDR_Notification_Event__e platformEvent
  );

  /**
   * @description create's events, publishes them, and then clears the queue.
   */
  public override void publishEvents() {
    List<IDR_Notification_Event__e> events = createEvents();
    if (!events.isEmpty()) {
      PlatformEventUtils.publishEvents(events);
    }
    clear();
  }

  /**
   * @description clear's the queue.
   */
  protected abstract void clear();
}
