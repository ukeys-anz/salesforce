/**
 *
 * @author Hrushikesh Pathak
 * @since 11/2023
 * @description BOH Lead Methods
 */
public with sharing class BOHLeadActions {
  private static BOHLeadActions instance;
  private List<BOH_Lead_Auto_Closure_Mapping__mdt> bohLeadMappingList;
  private Map<String, Map<String, Decimal>> bohMap;

  /**
   * @description Constructor to get the BOH lead mapping
   */
  private BOHLeadActions() {
    this.bohLeadMappingList = BOH_Lead_Auto_Closure_Mapping__mdt.getAll()
      .values();
    this.bohMap = new Map<String, Map<String, Decimal>>();
    for (BOH_Lead_Auto_Closure_Mapping__mdt m : this.bohLeadMappingList) {
      if (!this.bohMap.containsKey(m.Lead_Source__c)) {
        this.bohMap.put(m.Lead_Source__c, new Map<String, Decimal>());
      }
      this.bohMap.get(m.Lead_Source__c)
        .put(m.Opportunity_Type__c, m.Lead_Auto_Closure_Days__c);
    }
  }

  /**
   * @description gets the instance of this singleton
   * @return BOHLeadActions gets an instance of this class.
   */
  public static BOHLeadActions getInstance() {
    if (instance == null) {
      instance = new BOHLeadActions();
    }
    return instance;
  }

  /**
   * @description setBOHLeadFlag is called to set the Is_BOH_Lead__c flag
   * @param records The List of Lead record
   */
  public void setBOHLeadFlag(List<Lead> records) {
    for (Lead record : records) {
      record.Is_BOH_Lead__c = (String.isNotBlank(record.LeadSource) &&
      String.isNotBlank(record.OpportunityType__c) &&
      this.bohMap.containsKey(record.LeadSource) &&
      this.bohMap.get(record.LeadSource)
        .containsKey(record.OpportunityType__c) &&
      record.RecordTypeId == GetHelpConstants.LEAD_ANZX_RT_ID);
    }
  }

  /**
   * @description getDaysToAutoCloseBOHLead is called to get how many days BOH lead should be auto closed
   * @param record The Lead record
   * @return Decimal returns the number of days in which case should be auto closed.
   */
  public Integer getDaysToAutoCloseBOHLead(Lead record) {
    return record.Is_BOH_Lead__c
      ? Integer.valueOf(
          this.bohMap.get(record.LeadSource).get(record.OpportunityType__c)
        )
      : null;
  }
}
