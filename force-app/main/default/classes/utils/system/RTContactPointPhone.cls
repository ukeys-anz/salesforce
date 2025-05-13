/**
 * @author Naman Garg
 * @since April'25
 * @description Holds cached Contact Point Phone Record Types.
 */
public class RTContactPointPhone {
  static QueryRT base = QueryRT.of(ContactPointPhone.SObjectType);
  public static Id organisation = base.getId('Organisation');
  public static Id individual = base.getId('Individual');
}
