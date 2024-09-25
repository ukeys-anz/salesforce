/**
 * @author Naman Garg
 * @since Sept 2024
 * @description Holds cached Contact Record Types.
 */
public class RTContact {
  static QueryRT base = QueryRT.of(Contact.SObjectType);

  public static Id organisation = base.getId('Organisation');
}
