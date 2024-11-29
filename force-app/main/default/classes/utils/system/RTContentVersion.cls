/**
 * @author Lance Shi
 * @since Nov 2024
 * @description Holds cached Content Version Record Types.
 */
public class RTContentVersion {
  static QueryRT base = QueryRT.of(ContentVersion.SObjectType);

  public static Id cfaasFile = base.getId('CFaaS_File');
  public static Id file = base.getId('File');
  public static Id idrAttachment = base.getId('IDR_Attachment');
  public static Id idrFile = base.getId('IDR_File');
  public static Id systemicIssueFile = base.getId('Systemic_Issue_File');
  public static Id daonFile = base.getId('DAON_File');
}
