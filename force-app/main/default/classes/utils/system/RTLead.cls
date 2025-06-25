/**
 * @author Naman Garg
 * @since Nov 2024
 * @description Holds cached Lead Record Types.
 */
public class RTLead {
  static QueryRT base = QueryRT.of(Lead.SObjectType);

  public static Id commercialLead = base.getId('CCRM_Lead');
  public static Id mlcrmLead = base.getId('MLCRM_Lead');
  public static Id referralLead = base.getId('Referral');
  public static Id anzxLead = base.getId('ANZX_Leads');

  /**
   * @description Get the record type info for a given record type id
   * @param recordTypeId The record type id
   * @return The record type info
   */
  public static RecordTypeInfo get(Id recordTypeId) {
    return base.get(recordTypeId);
  }
}
