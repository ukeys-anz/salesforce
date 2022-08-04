/**
 * @author Adam Smith
 * @since 20220725
 * @description Abstract Base Class for creating Platform Events
 */
public with sharing abstract class PlatformEventCreator {
  /**
   * @description abstract method to create a base instance of the platform event
   * place mandatory things that are consistent across all Platform Events of that type.
   * @param targetsObject the sObject that is the target of the platform event.
   * @return base event
   */
  protected abstract SObject createBaseEvent(SObject targetsObject);

  /**
   * @description gets data for this platform event creator.
   * @param objects List<SObject> of objects for which to get the data.
   * @return Map<Id,SObject> Map of Data.
   */
  protected virtual Map<Id, SObject> getData(List<SObject> objects) {
    return new Map<Id, SObject>();
  }

  /**
   * @description checks to see if an object is a valid target for this Platform Event Creator
   * @param targetObject object of which to test validity.
   * @return Boolean true if this creator can be used for this object.
   */
  public abstract Boolean isValidObject(SObject targetObject);

  /**
   * @description publishes events
   */
  public abstract void publishEvents();
}
