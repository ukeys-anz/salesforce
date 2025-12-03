/**
 * @author       : Ayushi Gupta
 * @since        : June 2025
 * @description  : This is the helper class for CommercialLeadActions.
 **/
public with sharing class CommercialLeadActionsHelper {
  private static final LeadActionsRepository LEAD_ACTION_REPOSITORY = (LeadActionsRepository) Lib_InstanceProvider.forType(
    LeadActionsRepository.class
  );

  private static final String PRIMARY_CONTACT_MOBILE = 'Mobile';
  private static final String PRIMARY_CONTACT_WORK = 'Work Phone';
  private static final String PRIMARY_CONTACT_HOME = 'Home Phone';
  private final static String PROSPECT = 'Prospect';
  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param aarList Account-Account relationship records
   * @return `Map<Id, Set<Id>>`
   */
  public static Map<Id, Set<Id>> formAccountIdToCLGIdsMap(
    List<FinServ__AccountAccountRelation__c> aarList
  ) {
    Map<Id, Set<Id>> accIdToClgIdsMap = new Map<Id, Set<Id>>();
    for (FinServ__AccountAccountRelation__c aarRecord : aarList) {
      if (!accIdToClgIdsMap.containsKey(aarRecord.FinServ__Account__c)) {
        accIdToClgIdsMap.put(aarRecord.FinServ__Account__c, new Set<Id>());
      }
      accIdToClgIdsMap.get(aarRecord.FinServ__Account__c)
        .add(aarRecord.FinServ__RelatedAccount__c);
    }
    return accIdToClgIdsMap;
  }

  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param accIdToClgIdsMap map of accountId to CLGIds
   * @param clgAccountList list of accounts
   */
  public static void addCLGAccountToMap(
    Map<Id, Set<Id>> accIdToClgIdsMap,
    List<Account> clgAccountList
  ) {
    for (Account accRec : clgAccountList) {
      if (!accIdToClgIdsMap.containsKey(accRec.Id)) {
        accIdToClgIdsMap.put(accRec.Id, new Set<Id>());
      }
      accIdToClgIdsMap.get(accRec.Id).add(accRec.Id);
    }
  }

  /**
   * @description : This is used to validate the CLG association on Lead
   * @param filteredLeadsList Lead records
   * @param accMap Map of Account
   * @param accIdToClgIdsMap Map of account Id to related CLG Id map
   */
  public static void validateAndPopulateCLGInfo(
    List<Lead> filteredLeadsList,
    Map<Id, Account> accMap,
    Map<Id, Set<Id>> accIdToClgIdsMap
  ) {
    String selectAnyCLGErrorMsg = System.Label.Select_Any_CLG_Error_Message;
    String selectRelatedCLGErrorMsg = System.Label.Select_Related_CLG_Error_Message;
    String noCLGAvailableErrorMsg = System.Label.No_CLG_for_Customer;
    for (Lead leadRecord : filteredLeadsList) {
      Set<Id> clgIdsSet = accIdToClgIdsMap.get(
        leadRecord.FinServ__RelatedAccount__c
      ) ?? new Set<Id>();

      if (leadRecord.CLG_Name__c == null) {
        if (!clgIdsSet.isEmpty()) {
          leadRecord.CLG_Name__c.addError(selectAnyCLGErrorMsg);
        }
        continue;
      }
      if (clgIdsSet.isEmpty()) {
        leadRecord.CLG_Name__c.addError(noCLGAvailableErrorMsg);
        continue;
      }
      if (!clgIdsSet.contains(leadRecord.CLG_Name__c)) {
        leadRecord.CLG_Name__c.addError(selectRelatedCLGErrorMsg);
        continue;
      }
      setValueFromAccount(leadRecord, accMap.get(leadRecord.CLG_Name__c));
    }
  }

  /**
   * @description : This is used to form the Account Id to related CLG Ids Map
   * @param aarList Account-Account relationship records
   * @return `Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>`
   */
  public static Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> formAccountIdToCLGIdAARMap(
    List<FinServ__AccountAccountRelation__c> aarList
  ) {
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdsAARMap = new Map<Id, Map<Id, FinServ__AccountAccountRelation__c>>();
    for (FinServ__AccountAccountRelation__c aarRecord : aarList) {
      if (!accIdToClgIdsAARMap.containsKey(aarRecord.FinServ__Account__c)) {
        accIdToClgIdsAARMap.put(
          aarRecord.FinServ__Account__c,
          new Map<Id, FinServ__AccountAccountRelation__c>()
        );
      }
      accIdToClgIdsAARMap.get(aarRecord.FinServ__Account__c)
        .put(aarRecord.FinServ__RelatedAccount__c, aarRecord);
    }
    return accIdToClgIdsAARMap;
  }

  /**
   * @description : This is used to populate the CLG and CPID Info on Lead
   * @param filteredLeadsList Lead records
   * @param accMap Map of Account
   * @param accIdToClgIdAARMap Map of account Id to related CLG Id map
   */
  public static void populateClgCpidInfoOnLead(
    List<Lead> filteredLeadsList,
    Map<Id, Account> accMap,
    Map<Id, Map<Id, FinServ__AccountAccountRelation__c>> accIdToClgIdAARMap
  ) {
    for (Lead leadRecord : filteredLeadsList) {
      Account accRec = accMap.get(leadRecord.FinServ__RelatedAccount__c);
      Boolean isClgAccount = accRec?.RecordTypeId == RTAccount.clgAccount;
      Boolean isAccountInMap = accIdToClgIdAARMap.containsKey(
        leadRecord.FinServ__RelatedAccount__c
      );

      if (isClgAccount) {
        CommercialLeadActionsHelper.setValueFromAccount(
          leadRecord,
          isAccountInMap ? null : accRec
        );
        continue;
      }
      if (!isAccountInMap) {
        //when customer = org and no related CLG present then nullify CLG fields
        CommercialLeadActionsHelper.setValueFromAccount(leadRecord, null);
        continue;
      }
      Map<Id, FinServ__AccountAccountRelation__c> clgIdToAARMap = accIdToClgIdAARMap.get(
        leadRecord.FinServ__RelatedAccount__c
      );
      if (clgIdToAARMap.size() != 1) {
        CommercialLeadActionsHelper.setValueFromAccount(leadRecord, null);
        continue;
      }
      FinServ__AccountAccountRelation__c aar = clgIdToAARMap.values()[0];
      CommercialLeadActionsHelper.setValueFromAccount(
        leadRecord,
        aar.FinServ__RelatedAccount__r
      );
    }
  }

  /**
   * @description : It will map primary contact method according to phone fields
   * @name : updatePrimaryContactMethod
   * @param filteredLeadList List of Lead records
   */
  public static void updatePrimaryContactMethod(List<Lead> filteredLeadList) {
    for (Lead leadRecord : filteredLeadList) {
      //check phone fields in priority order
      if (String.isNotBlank(leadRecord.MobilePhone)) {
        leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_MOBILE;
        continue;
      }
      if (String.isNotBlank(leadRecord.Work_Phone__c)) {
        leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_WORK;
        continue;
      }
      if (String.isNotBlank(leadRecord.Home_Phone__c)) {
        leadRecord.Primary_Contact_Method__c = PRIMARY_CONTACT_HOME;
        continue;
      }
      leadRecord.Primary_Contact_Method__c = null;
    }
  }

  /**
   * @description This method is to get prospect customers
   * @param filteredLeads List of lead records
   * @return Set of accountId
   */
  public static Set<Id> getProspectCustomers(List<Lead> filteredLeads) {
    Set<Id> customerIds = ListUtil.getIds(
      filteredLeads,
      Lead.FinServ__RelatedAccount__c
    );
    List<Account> prospectCustomers = LEAD_ACTION_REPOSITORY.getAccountRecords(
      customerIds,
      PROSPECT
    );
    return ListUtil.getIds(prospectCustomers, Account.Id);
  }

  /**
   * @description This method updates New_to_Bank__c flag
   * @param filteredLeads List of lead records
   * @param prospectCustomerIds Set of prospect customer Ids
   */
  public static void updateNewToBankFlag(
    List<Lead> filteredLeads,
    Set<Id> prospectCustomerIds
  ) {
    for (Lead leadRec : filteredLeads) {
      leadRec.New_to_Bank__c = String.isBlank(
          leadRec.FinServ__RelatedAccount__c
        ) || prospectCustomerIds.contains(leadRec.FinServ__RelatedAccount__c)
        ? 'Yes'
        : 'No';
    }
  }

  /**
   * @description This method gets updated AZ records
   * @param filteredLeadMap filtered lead map
   * @param listOfA2ZReviews List of A-Z records
   * @return List<A_Z_Review__c>
   */
  public static List<A_Z_Review__c> getUpdatedAZRecords(
    Map<Id, Lead> filteredLeadMap,
    List<A_Z_Review__c> listOfA2ZReviews
  ) {
    List<A_Z_Review__c> filteredA2ZReviews = new List<A_Z_Review__c>();
    for (A_Z_Review__c azRecord : listOfA2ZReviews) {
      if (!filteredLeadMap.containsKey(azRecord.Lead__c)) {
        continue;
      }
      azRecord.Customer__c = filteredLeadMap.get(azRecord.Lead__c)
        .FinServ__RelatedAccount__c;
      filteredA2ZReviews.add(azRecord);
    }
    return filteredA2ZReviews;
  }

  /**
   * @description This method extends the expiry date when:
   * Log Response created with Follow up date AND Follow up date is changed
   * @name updateExpiryDateWhenFollowUpChanged
   * @param records Lead record.
   * @param mapTask Map of Task
   * @return List<Lead>
   */
  public static List<Lead> updateExpiryDateWhenFollowUpChanged(
    List<Lead> records,
    Map<Id, Task> mapTask
  ) {
    Integer minDays = integer.valueOf(Label.CCRM_MinDaysExpiryDateExtends);
    Integer maxdays = integer.valueOf(Label.CCRM_MaxDaysExpiryDateExtends);
    List<Lead> lstofUpdatedRecords = new List<Lead>();
    for (Lead record : records) {
      if (mapTask.get(record.Id)?.ActivityDate == null) {
        continue;
      }
      Date activityDate = mapTask.get(record.Id).ActivityDate;
      Date minActivityDate = activityDate.addDays(minDays);
      Date maxExpiryDate = record.Expiry_Date__c.addDays(maxdays);
      record.Expiry_Date__c = minActivityDate > maxExpiryDate
        ? maxExpiryDate
        : minActivityDate;
      lstofUpdatedRecords.add(record);
    }
    return lstofUpdatedRecords;
  }

  /**
   * @description : This is used to populate the CLG and CPID Info on Lead from Account
   * @param leadRecord Lead record
   * @param accRecord Account record
   */
  public static void setValueFromAccount(Lead leadRecord, Account accRecord) {
    leadRecord.CLG_Name__c = accRecord?.Id;
    leadRecord.CLG_ID__c = accRecord?.CLG__c;
    leadRecord.CPID__c = accRecord?.CPID__c;
    leadRecord.CPID_Owner__c = accRecord?.Controlling_Post__r?.OwnerId;
  }

  /**
   * @description : This is used to populate the contatc Info on Lead from Individual ETB Account
   * name populateContactInfoForInd
   * @param filteredLeadsList filtered Lead records
   * @param accMap Map of Id and Account
   */
  public static void populateContactInfoForInd(
    List<Lead> filteredLeadsList,
    Map<Id, Account> accMap
  ) {
    for (Lead leadRec : filteredLeadsList) {
      Account accRec = accMap.get(leadRec.FinServ__RelatedAccount__c);
      if (accRec == null) {
        continue;
      }
      leadRec.MobilePhone = leadRec.MobilePhone ??
        santizePhoneNumber(accRec.PersonOtherPhone);
      leadRec.Work_Phone__c = leadRec.Work_Phone__c ??
        santizePhoneNumber(accRec.Phone);
      leadRec.Home_Phone__c = leadRec.Home_Phone__c ??
        santizePhoneNumber(accRec.PersonHomePhone);
      leadRec.Email = leadRec.Email ?? accRec.Other_Email__c;
      if (leadRec.Primary_Contact_Method__c == null) {
        leadRec.Primary_Contact_Method__c = (leadRec.MobilePhone != null)
          ? 'Mobile'
          : ((leadRec.Work_Phone__c != null)
              ? 'Work Phone'
              : ((leadRec.Home_Phone__c != null) ? 'Home Phone' : null));
      }
    }
  }

  /**
   * @description : This is used to sanitize the Phone number
   * name santizePhoneNumber
   * @param phoneNumber Phone Number from account
   * @return String return correct phone number after sanitize
   */
  private static String santizePhoneNumber(String phoneNumber) {
    if (phoneNumber == null) {
      return phoneNumber;
    }
    if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.replaceFirst('0', '+61');
    }
    return phoneNumber;
  }
}
