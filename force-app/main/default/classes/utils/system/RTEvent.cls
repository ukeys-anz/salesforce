/**
 * @author Pragya Awasthi
 * @since 26 Aug 2025
 * @description Holds cached Event Record Type.
 */
public class RTEvent {
  static QueryRT base = QueryRT.of(Event.SObjectType);
  public static Id mlEvent = base.getId('ML_Event');
}
