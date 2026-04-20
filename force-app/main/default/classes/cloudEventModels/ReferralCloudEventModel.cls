/**
 * @author       : Advait Yermalkar
 * @since        : 02-19-2025
 * @description  : Model class for referral lead cloud events which are sent to IKNOW.
 **/
public without sharing class ReferralCloudEventModel extends CloudEventModel {
  public static final String REFERRAL_CE_SOURCE = 'anzx.salesforce.ccrm.v1alpha1';
  public static final String SOURCE_OF_BUSINESS = 'Internal Referral';
  public static final Set<String> FIELDS_TO_CONCATENATE = new Set<String>{
    'ReferrerName', // Referrer FirstName & LastName
    'Company', // For exisiting customer use Account Name | For New customers use Company
    'Name', // Lead.Name
    'Primary_Contact_Method__c',
    'Phone', // Mobile | Home_Phone__c | Work_Phone__c
    'Email' // Email
  };
  public static final Map<String, String> CONTACT_METHOD_TO_FIELD = new Map<String, String>{
    'Home Phone' => 'Home_Phone__c',
    'Work Phone' => 'Work_Phone__c',
    'Mobile' => 'MobilePhone'
  };
  public static final String CONCATENATE_TEMPLATE = 'Referrer - {0}; Company - {1}; Contact - {2}; Primary Contact Method - {3}; {3} - {4}; Email - {5};';
  private static final CommercialReferralLeadRepository COMMERCIAL_REFERRAL_LEAD_REPOSITORY = (CommercialReferralLeadRepository) Lib_InstanceProvider.forType(
    CommercialReferralLeadRepository.class
  );

  /**
   * @description  Constructor for ReferralCloudEventModel
   * @param theLead  lead record
   * @param systemdata  system data
   * @param leadOwnerMap leadId to Owner/Referrer map
   * @param existingCustomerMap leadId to Customer map
   *
   **/
  public ReferralCloudEventModel(
    Lead theLead,
    CloudEventModel.CloudEventSystemModel systemdata,
    Map<Id, User> leadOwnerMap,
    Map<Id, Account> existingCustomerMap
  ) {
    super();
    this.ce_subject = 'LeadNumber/' + theLead.Lead_Auto_Number__c;
    this.ce_partitionkey = 'LeadNumber/' + theLead.Lead_Auto_Number__c;
    this.systemData = systemdata;
    this.ce_source = REFERRAL_CE_SOURCE;
    this.ce_type = System.Label.CCRM_REFERRAL_TO_IKNOW_EVENT_CE_TYPE;
    this.ce_data = new ReferralCloudEventDataModel(
      theLead,
      leadOwnerMap,
      existingCustomerMap
    );
  }

  /**
   * @description  : Referral Cloud Event Data Model
   */
  public virtual class ReferralCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description  ReferralId --> Lead.Id
     */
    public String referralId { get; set; }
    /**
     * @description  ReferralNo --> Lead.Lead_Auto_Number__c
     */
    public String referralNo { get; set; }
    /**
     * @description  customerId --> Lead.Customer_ID__c
     */
    public String customerId { get; set; }
    /**
     * @description  channel --> Lead.Channel__c
     */
    public String channel { get; set; }
    /**
     * @description  referralCategory --> Lead.Referral_Category__c
     */
    public String referralCategory { get; set; }
    /**
     * @description  customerNeed --> Lead.FinServ__ExpressedInterest__c
     */
    public String customerNeed { get; set; }
    /**
     * @description  notes --> Lead.Note__c
     */
    public String notes { get; set; }
    /**
     * @description  referrerId --> Lead.ownerId.Lan_Id__C
     */
    public String referrerId { get; set; }
    /**
     * @description  refereeId --> Lead.FinServ__ReferredByUser__c.Lan_Id__c
     */
    public String refereeId { get; set; }
    /**
     * @description  companyName --> Lead.FinServ__RelatedAccount__c.Name
     */
    public String companyName { get; set; }
    /**
     * @description  sourceOfBusiness
     */
    public String sourceOfBusiness { get; set; }
    /**
     * @description  entityType --> Lead.Entity_Type__c
     */
    public String entityType { get; set; }
    /**
     * @description  productFUM --> Lead.FinServ__PotentialValue__c
     */
    public String productFUM { get; set; }

    /**
     * @description  Constructor for ReferralCloudEventDataModel
     * @param theLead  lead record
     * @param leadOwnerMap leadId to Owner/Referrer map
     * @param existingCustomerMap leadId to Customer map
     **/
    public ReferralCloudEventDataModel(
      Lead theLead,
      Map<Id, User> leadOwnerMap,
      Map<Id, Account> existingCustomerMap
    ) {
      this.referralId = theLead.Id;
      this.referralNo = theLead.Lead_Auto_Number__c;
      this.channel = theLead.Channel__c;
      this.referralCategory = theLead.Referral_Category__c;
      this.customerNeed = theLead.Referral_Customer_Needs__c;
      this.notes = createNotesForEventToIknow(theLead, existingCustomerMap);
      this.referrerId = leadOwnerMap.get(theLead.FinServ__ReferredByUser__c)
        ?.Lan_Id__c;
      this.refereeId = leadOwnerMap.get(theLead.OwnerId)?.Lan_Id__c;
      this.sourceOfBusiness = SOURCE_OF_BUSINESS;
      // For exisiting customer use Account Name | For New customers use Company
      this.companyName = getCompanyName(theLead, existingCustomerMap);
      this.customerId = existingCustomerMap.get(
          theLead.FinServ__RelatedAccount__c
        )
        ?.Source_System_ID__c;
      String accRecTypeID = existingCustomerMap.get(
          theLead.FinServ__RelatedAccount__c
        )
        ?.RecordTypeId;
      if (String.isNotBlank(accRecTypeID)) {
        // Send Entity Type only for Existing Customers
        this.entityType = accRecTypeID == RTAccount.personAccount ? 'I' : 'C';
      }
      this.productFUM = theLead.FinServ__PotentialValue__c?.toString();
    }

    /**
     * @description  trim and Strip Html, append & preserve concatenated field data for max 4000 chars
     * @param theLead lead record
     * @param existingCustomerMap leadId to Customer map
     * @return String Collated Notes & Fields data to sent to iKnow
     **/
    private String createNotesForEventToIknow(
      Lead theLead,
      Map<Id, Account> existingCustomerMap
    ) {
      List<String> fieldsData = concatenateFieldData(
        theLead,
        existingCustomerMap
      );
      return createFinalNotes(theLead, fieldsData);
    }

    /**
     * @description create data for fields to be concatenated
     * @param theLead lead record
     * @param existingCustomerMap leadId to Customer map
     * @return List<String> fieldsData
     **/
    private List<String> concatenateFieldData(
      Lead theLead,
      Map<Id, Account> existingCustomerMap
    ) {
      List<String> fieldsData = new List<String>();
      List<User> referrerUser = COMMERCIAL_REFERRAL_LEAD_REPOSITORY.getUsers(
        new Set<Id>{ theLead.FinServ__ReferredByUser__c }
      );
      for (String eachField : FIELDS_TO_CONCATENATE) {
        if (eachField == 'ReferrerName') {
          fieldsData.add(getName(null, referrerUser[0]) ?? '');
          continue;
        }
        if (eachField == 'Company') {
          fieldsData.add(getCompanyName(theLead, existingCustomerMap) ?? '');
          continue;
        }
        if (eachField == 'Name') {
          fieldsData.add(getName(theLead, null) ?? '');
          continue;
        }
        if (eachField == 'Phone') {
          eachField = CONTACT_METHOD_TO_FIELD.get(
            String.valueOf(theLead.get('Primary_Contact_Method__c'))
          );
        }
        fieldsData.add(String.valueOf(theLead.get(eachField)));
      }
      return fieldsData;
    }

    /**
     * @description return lead name concatenated
     * @param theLead lead record
     * @param theReferrer user record
     * @return String FirstName + MiddleName + LastName
     **/
    private String getName(Lead theLead, User theReferrer) {
      if (theReferrer != null) {
        return TextUtils.concat(
          new Set<String>{ theReferrer.FirstName, theReferrer.LastName }
        );
      }
      return TextUtils.concat(
        new Set<String>{
          theLead.FirstName,
          theLead.MiddleName,
          theLead.LastName
        }
      );
    }

    /**
     * @description get Company Name or Account Name of Customer from lead
     * @param theLead lead record
     * @param existingCustomerMap leadId to Customer map
     * @return String CompanyName or Account Name
     **/
    private String getCompanyName(
      Lead theLead,
      Map<Id, Account> existingCustomerMap
    ) {
      return existingCustomerMap.get(theLead.FinServ__RelatedAccount__c)
        ?.Name ?? theLead.Company;
    }

    /**
     * @description create final notes for Event to Iknow
     * @param theLead lead record
     * @param fieldsData List of field data
     * @return String Notes data with concatenated Field Data
     **/
    private String createFinalNotes(Lead theLead, List<String> fieldsData) {
      String concatFieldData = String.format(CONCATENATE_TEMPLATE, fieldsData);
      String referralNotes = (theLead.Note__c);
      return (concatFieldData +
        ' Notes - ' +
        referralNotes?.stripHtmlTags())
        .trim()
        .left(3990);
    }
  }
}
