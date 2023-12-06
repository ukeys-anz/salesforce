/**
 *
 * @author Hrushikesh Pathak
 * @since 11/2023
 * @description BOH Lead Methods
 */
public with sharing class BOHLeadActions {
  private static final String BOH_DECLINED_STATUS = 'Declined';
  private static final String BOH_CLOSED_STATUS = 'Closed';
  private static final String BOH_AUTO_CLOSED_SUB_STATUS = 'Auto-closed';
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
   * @description isBOHLeadNeedAutoClosure is called to check if lead needs auto closure
   * @param record The Lead record
   * @return Boolean that shows if BOH lead needs to be auto closed or not
   */
  public Boolean isBOHLeadNeedAutoClosure(Lead record) {
    if (
      this.bohMap.get(record.LeadSource)?.get(record.OpportunityType__c) == null
    ) {
      return false;
    } else {
      return (Lib_SystemLog.getDifferenceInMinutes(
        record.CreatedDate,
        DateTime.now()
      ) >
      (Integer.valueOf(
        this.bohMap.get(record.LeadSource).get(record.OpportunityType__c)
      ) *
      24 *
      60));
    }
  }

  /**
   * @description autoCloseBOHLeads is called to auto close the BOH Leads
   * @param records The List<Lead> the list of BOH Leads which are not actioned
   */
  public static void autoCloseBOHLeads(List<Lead> records) {
    List<Lead> updatedLeads = new List<Lead>();
    if (records.isEmpty()) {
      return;
    }
    for (Lead record : records) {
      if (BOHLeadActions.getInstance().isBOHLeadNeedAutoClosure(record)) {
        record.Status = BOH_DECLINED_STATUS;
        record.SubStatus__c = BOH_AUTO_CLOSED_SUB_STATUS;
        updatedLeads.add(record);
      }
    }
    DMLUtil.updateRecords(updatedLeads, false, false);
  }

  /**
   * @description getPotentialMatchingCustomer is called to get potential customers whose email and phone matches with lead
   * @param mobileSet The set of lead mobile numbers
   * @param emailSet The set of lead emial ids
   * @return List<Account> with matching mobile or email with lead.
   */
  public static List<Account> getPotentialMatchingCustomer(
    Set<String> mobileSet,
    Set<String> emailSet
  ) {
    List<Account> potentialMatchingCustomers = [
      SELECT Id, FirstName, LastName, PersonMobilePhone, PersonEmail
      FROM Account
      WHERE
        RecordTypeId = :GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
        AND (PersonMobilePhone IN :mobileSet
        OR PersonEmail IN :emailSet)
    ];
    return potentialMatchingCustomers;
  }

  /**
   * @description populateExistingCustomer populate existing customer the customers that have matching details with the newly created lead
   * @param newRecords The lead records from Trigger.new()
   */
  public static void populateExistingCustomer(List<Lead> newRecords) {
    Map<String, Lead> leadByMobileMap = new Map<String, Lead>();
    Map<String, Lead> leadByEmailMap = new Map<String, Lead>();

    for (Lead record : newRecords) {
      if (record.Is_BOH_Lead__c) {
        if (String.isNotBlank(record.MobilePhone)) {
          leadByMobileMap.put(record.MobilePhone, record);
        }
        if (String.isNotBlank(record.Email)) {
          leadByEmailMap.put(record.Email, record);
        }
      }
    }

    Map<String, List<Account>> matchingCustomersByLeadIdMap = new Map<String, List<Account>>();

    for (
      Account poteAccount : getPotentialMatchingCustomer(
        leadByMobileMap.keySet(),
        leadByEmailMap.keySet()
      )
    ) {
      if (
        firstNameMobileEmailMatch(
          poteAccount,
          leadByMobileMap,
          leadByEmailMap
        ) ||
        lastNameMobileEmailMatch(
          poteAccount,
          leadByMobileMap,
          leadByEmailMap
        ) ||
        firstNameLastNameEmailMatch(poteAccount, leadByEmailMap)
      ) {
        addCustomerInMapByLeadEmail(
          poteAccount,
          matchingCustomersByLeadIdMap,
          leadByEmailMap.get(poteAccount.PersonEmail)
        );
      } else if (firstNameLastNameMobileMatch(poteAccount, leadByMobileMap)) {
        addCustomerInMapByLeadMobilePhone(
          poteAccount,
          matchingCustomersByLeadIdMap,
          leadByMobileMap.get(poteAccount.PersonMobilePhone)
        );
      }
    }
    setExistingCustomer(newRecords, matchingCustomersByLeadIdMap);
  }

  /**
   * @description setExistingCustomer populate existing customer field on lead
   * @param records The BOH lead records
   * @param matchingCustomersByLeadIdMap The map of email or mobile number to list of matching customers
   */
  public static void setExistingCustomer(
    List<Lead> records,
    Map<String, List<Account>> matchingCustomersByLeadIdMap
  ) {
    if (matchingCustomersByLeadIdMap.isEmpty()) {
      return;
    }

    for (Lead record : records) {
      if (record.Is_BOH_Lead__c) {
        if (matchingCustomersByLeadIdMap.containsKey(record.Email)) {
          record.FinServ__RelatedAccount__c = matchingCustomersByLeadIdMap.get(
              record.Email
            )[0]
            .Id;
        } else if (
          matchingCustomersByLeadIdMap.containsKey(record.MobilePhone)
        ) {
          record.FinServ__RelatedAccount__c = matchingCustomersByLeadIdMap.get(
              record.MobilePhone
            )[0]
            .Id;
        }
      }
    }
  }

  /**
   * @description addCustomerInMapByLeadEmail gets a list of potential matching customers by their corresponding lead Id
   * @param acc The account record to be added to the list
   * @param matchingCustomersByLeadIdMap A map of leads to be converted and their corresponding account Ids
   * @param leadRecord lead record matching the customer
   * @return Map<String, List<Account>> A map of lead id to the list of matching customers
   */
  public static Map<String, List<Account>> addCustomerInMapByLeadEmail(
    Account acc,
    Map<String, List<Account>> matchingCustomersByLeadIdMap,
    Lead leadRecord
  ) {
    if (matchingCustomersByLeadIdMap.containsKey(leadRecord.Email)) {
      matchingCustomersByLeadIdMap.get(leadRecord.Email).add(acc);
    } else {
      List<Account> matchingCustomers = new List<Account>();
      matchingCustomers.add(acc);
      matchingCustomersByLeadIdMap.put(leadRecord.Email, matchingCustomers);
    }
    return matchingCustomersByLeadIdMap;
  }

  /**
   * @description addCustomerInMapByLeadMobilePhone gets a list of potential matching customers by their corresponding lead Id
   * @param acc The account record to be added to the list
   * @param matchingCustomersByLeadIdMap A map of leads to be converted and their corresponding account Ids
   * @param leadRecord lead record matching the customer
   * @return Map<String, List<Account>> A map of lead id to the list of matching customers
   */
  public static Map<String, List<Account>> addCustomerInMapByLeadMobilePhone(
    Account acc,
    Map<String, List<Account>> matchingCustomersByLeadIdMap,
    Lead leadRecord
  ) {
    if (matchingCustomersByLeadIdMap.containsKey(leadRecord.MobilePhone)) {
      matchingCustomersByLeadIdMap.get(leadRecord.MobilePhone).add(acc);
    } else {
      List<Account> matchingCustomers = new List<Account>();
      matchingCustomers.add(acc);
      matchingCustomersByLeadIdMap.put(
        leadRecord.MobilePhone,
        matchingCustomers
      );
    }
    return matchingCustomersByLeadIdMap;
  }

  /**
   * @description firstNameMobileEmailMatch checks if a account's firstname, mobile, email matches those of an lead
   * @param acc A account record
   * @param leadByMobileMap A map of leads and their mobile numbers
   * @param leadByEmailMap A map of leads and their emails
   * @return Boolean If the account's firstname, mobile, email match with the leads's firstname, mobile, email
   */
  private static Boolean firstNameMobileEmailMatch(
    Account acc,
    Map<String, Lead> leadByMobileMap,
    Map<String, Lead> leadByEmailMap
  ) {
    return (acc.FirstName.toLowerCase() ==
    leadByEmailMap.get(acc.PersonEmail)?.Firstname.toLowerCase() &&
    acc.FirstName.toLowerCase() ==
    leadByMobileMap.get(acc.PersonMobilePhone)?.Firstname.toLowerCase());
  }

  /**
   * @description lastNameMobileEmailMatch checks if a account's lastname, mobile, email matches those of an lead
   * @param acc A account record
   * @param leadByMobileMap A map of leads and their mobile numbers
   * @param leadByEmailMap A map of leads and their emails
   * @return Boolean If the account's lastname, mobile, email match with the leads's lastname, mobile, email
   */
  private static Boolean lastNameMobileEmailMatch(
    Account acc,
    Map<String, Lead> leadByMobileMap,
    Map<String, Lead> leadByEmailMap
  ) {
    return (acc.Lastname.toLowerCase() ==
    leadByEmailMap.get(acc.PersonEmail)?.Lastname.toLowerCase() &&
    acc.Lastname.toLowerCase() ==
    leadByMobileMap.get(acc.PersonMobilePhone)?.Lastname.toLowerCase());
  }

  /**
   * @description firstNameLastNameMobileMatch checks if a account's firstname, lastname, mobile matches those of an lead
   * @param acc A account record
   * @param leadByMobileMap A map of leads and their mobile numbers
   * @return Boolean If the account's firstname, lastname, email match with the leads's firstname, lastname, mobile
   */
  private static Boolean firstNameLastNameMobileMatch(
    Account acc,
    Map<String, Lead> leadByMobileMap
  ) {
    return (acc.FirstName.toLowerCase() ==
    leadByMobileMap.get(acc.PersonMobilePhone)?.FirstName.toLowerCase() &&
    acc.Lastname.toLowerCase() ==
    leadByMobileMap.get(acc.PersonMobilePhone)?.Lastname.toLowerCase());
  }

  /**
   * @description firstNameLastNameEmailMatch checks if account's firstname, lastname, email matches those of an lead
   * @param acc A account record
   * @param leadByEmailMap A map of leads and their emails
   * @return Boolean If the account's firstname, lastname, email match with the leads's firstname, lastname, email
   */
  private static Boolean firstNameLastNameEmailMatch(
    Account acc,
    Map<String, Lead> leadByEmailMap
  ) {
    return (acc.FirstName.toLowerCase() ==
    leadByEmailMap.get(acc.PersonEmail)?.FirstName.toLowerCase() &&
    acc.Lastname.toLowerCase() ==
    leadByEmailMap.get(acc.PersonEmail)?.Lastname.toLowerCase());
  }

  /**
   * @description convertLeads convert leads into their matching accounts
   * @param leadsList A list fo leads to be converted
   */
  public void convertLeads(List<Lead> leadsList) {
    List<Database.LeadConvert> converts = new List<Database.LeadConvert>();
    List<Database.LeadConvertResult> lcResults = new List<Database.LeadConvertResult>();
    LeadStatus convertedStatus = [
      SELECT MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];

    for (Lead l : leadsList) {
      if (
        l.Is_BOH_Lead__c &&
        l.Status == BOH_CLOSED_STATUS &&
        l.FinServ__RelatedAccount__c != null
      ) {
        Database.LeadConvert convert = new Database.LeadConvert();
        convert.setLeadId(l.Id);
        convert.setAccountId(l.FinServ__RelatedAccount__c);
        convert.setConvertedStatus(convertedStatus.MasterLabel);
        convert.setDoNotCreateOpportunity(true);
        converts.add(convert);
      }
    }
    lcResults = Database.convertLead(converts);
    List<Contact> contactList = new List<Contact>();
    for (Database.LeadConvertResult lcr : lcResults) {
      if (!lcr.isSuccess()) {
        Logger.error(
          'Account_Id: ' +
          lcr.getAccountId() +
          '; Lead_Id: ' +
          lcr.getLeadId() +
          '; Error_Message: ' +
          lcr.getErrors()[0].getMessage()
        );
      } else {
        contactList.add(new Contact(Id = lcr.getContactId()));
      }
    }
    Logger.saveLog();

    if (!contactList.isEmpty()) {
      deleteAutoCreatedContacts(contactList);
    }
  }

  /**
   * @description delete auto created contacts post lead conversion
   * @param contactList list of contacts from lead conversion
   */
  private void deleteAutoCreatedContacts(List<Contact> contactList) {
    if (contactList.isEmpty()) {
      return;
    }
    //Separate contactList into org contacts vs person accounts
    List<Contact> orgContactList = new List<Contact>();
    Set<Id> personContactsIdSet = new Set<Id>();
    for (Contact contactRec : [
      SELECT id, isPersonAccount
      FROM contact
      WHERE id IN :contactList
    ]) {
      if (contactRec.isPersonAccount) {
        personContactsIdSet.add(contactRec.id);
      } else {
        orgContactList.add(contactRec);
      }
    }
    if (!orgContactList.isEmpty()) {
      DMLUtil.deleteRecords(
        orgContactList,
        DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
        DMLUtil.SYSTEM_MODE
      );
    }
    if (!personContactsIdSet.isEmpty()) {
      List<OpportunityContactRole> personOpportunityContactRoleList = [
        SELECT id, ContactId
        FROM OpportunityContactRole
        WHERE ContactId IN :personContactsIdSet
      ];
      if (!personOpportunityContactRoleList.isEmpty()) {
        DMLUtil.deleteRecords(
          personOpportunityContactRoleList,
          DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
          DMLUtil.SYSTEM_MODE
        );
      }
    }
  }
}
