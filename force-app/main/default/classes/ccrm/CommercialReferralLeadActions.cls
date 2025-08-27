/**
 * @author       : Naman Garg
 * @since        : Jan 2025
 * @description  : CommercialReferralLeadActions is the actions class for CommercialReferralLeadTriggerHandler
 **/
public with sharing class CommercialReferralLeadActions {
  @testVisible
  private static final String REFERRAL_STATUS_NEW = 'New';
  @testVisible
  private static final String REFERRAL_STATUS_IN_PROGRESS = 'In Progress';
  @testVisible
  private static final String REFERRAL_LEAD_ACCESS = 'Read';
  @testVisible
  private static final String NOTIFICATION_TITLE = 'New Referral';
  @testVisible
  private static final String NOTIFICATION_BODY = 'You have been assigned with a new Referral';
  private static final String CUSTOM_NOTIFICATION = 'Commercial_Referral_Notification';
  private static final String CHANNEL_PRIVATE_BANK = 'Private Bank';
  private static final String CHANNEL_COMMERCIAL = 'Commercial';
  private static final String LEAD_OUTCOME_REFERRED = 'Referred';
  private static final String CCRM = 'CCRM-';

  private static final Set<SobjectField> CONTACT_INFO_FIELDS = new Set<SObjectField>{
    Lead.Home_Phone__c,
    Lead.Work_Phone__c,
    Lead.MobilePhone
  };

  private static final DmlRepository DML_REPO = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final CommercialReferralLeadRepository REFERRAL_LEAD_REPO = (CommercialReferralLeadRepository) Lib_InstanceProvider.forType(
    CommercialReferralLeadRepository.class
  );

  /**
   * @description This is used to populate the referral status when the owner changes
   * @name updateReferralStatus
   * @param records List of new records
   * @param oldMap map of old records
   */
  public static void updateReferralStatus(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredReferralLeadsList = ListUtil.filter(records, oldMap)
      .equals(Lead.Referral_Status__c, REFERRAL_STATUS_NEW)
      .changed(Lead.OwnerId)
      .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
      .toList();

    ListUtil.setField(
      filteredReferralLeadsList,
      Lead.Referral_Status__c,
      REFERRAL_STATUS_IN_PROGRESS
    );
  }

  /**
   * @description This is used to populate the referral status banker assigned iKnow referrals
   * @name updateReferralStatus
   * @param records List of new records
   */
  public static void updateIknowReferralStatus(List<Lead> records) {
    List<Lead> filteredIknowReferralLeadsList = ListUtil.filter(records)
      .equals(Lead.Referral_Status__c, REFERRAL_STATUS_NEW)
      .isNull(Lead.Assignee_Group__c)
      .isNotNull(Lead.External_Id__c)
      .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
      .toList();

    ListUtil.setField(
      filteredIknowReferralLeadsList,
      Lead.Referral_Status__c,
      REFERRAL_STATUS_IN_PROGRESS
    );
  }

  /**
   * @description This is used to share the referral record with the Internal Referee when Owner changes
   * @name shareReferralRecord
   * @param records List of new records
   * @param oldMap map of old records
   */
  public static void shareReferralRecord(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      //Filter Lead record where owner changes and the ownerId != FinServ__ReferredByUser__c Id
      List<Lead> filteredReferralLeadsList = ListUtil.filter(records, oldMap)
        .changed(Lead.OwnerId)
        .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
        .toList();

      //share the read access with the FinServ__ReferredByUser__c users
      List<LeadShare> refLeadShareRecordList = generateReferralLeadShareList(
        filteredReferralLeadsList
      );

      DML_REPO.doInsert(
        refLeadShareRecordList,
        new DmlConfig().withoutSharing()
      );
    } catch (Exception e) {
      Logger.error('Error occured while create sharing records', e).save();
    }
  }

  /**
   * @description This is used to share the referral record with the Internal Referee when Owner changes
   * @name generateReferralLeadShareList
   * @param filteredReferralLeadsList List of filtered referral lead records
   * @return List<LeadShare>
   */
  @testVisible
  private static List<LeadShare> generateReferralLeadShareList(
    List<Lead> filteredReferralLeadsList
  ) {
    List<LeadShare> refLeadShareRecordList = new List<LeadShare>();
    for (Lead referralRec : filteredReferralLeadsList) {
      LeadShare refLeadShareRecord = new LeadShare();
      refLeadShareRecord.LeadId = referralRec.Id;
      refLeadShareRecord.UserOrGroupId = referralRec.FinServ__ReferredByUser__c;
      refLeadShareRecord.LeadAccessLevel = REFERRAL_LEAD_ACCESS;
      refLeadShareRecordList.add(refLeadShareRecord);
    }
    return refLeadShareRecordList;
  }

  /**
   * @description This is used to send bell notification when owner changes
   * @name sendBellNotification
   * @param records List of new records
   * @param oldMap map of old records
   */
  public static void sendBellNotification(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      //Filter Lead record where owner changes and the ownerId != FinServ__ReferredByUser__c Id
      List<Lead> filteredReferralLeadsList = ListUtil.filter(records, oldMap)
        .equals(Lead.Referral_Status__c, REFERRAL_STATUS_IN_PROGRESS)
        .changed(Lead.OwnerId)
        .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
        .toList();

      //send bell notification
      sendNotification(filteredReferralLeadsList);
    } catch (Exception e) {
      Logger.error('Error occured while sending notification', e).save();
    }
  }

  /**
   * @description This is used to send bell notification when owner changes
   * @name sendBellNotificationIknowReferral
   * @param records List of new records
   */
  public static void sendBellNotificationIknowReferral(List<Lead> records) {
    try {
      //Filter Lead record where owner changes and the ownerId != FinServ__ReferredByUser__c Id
      List<Lead> filteredReferralLeadsList = ListUtil.filter(records)
        .equals(Lead.Referral_Status__c, REFERRAL_STATUS_IN_PROGRESS)
        .isNull(Lead.Assignee_Group__c)
        .isNotNull(Lead.External_Id__c)
        .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
        .toList();

      //send bell notification
      sendNotification(filteredReferralLeadsList);
    } catch (Exception e) {
      Logger.error('Error occured while sending notification', e).save();
    }
  }

  /**
   * @description This is used to send bell notification
   * @name sendNotification
   * @param filteredReferralLeadsList List of records where owner changes
   */
  @TestVisible
  private static void sendNotification(List<Lead> filteredReferralLeadsList) {
    Id referralNotificationId = CommonUtil.getCustomNotificationTypeByName(
        CUSTOM_NOTIFICATION
      )
      .Id;

    Set<Id> userIds = ListUtil.getIds(filteredReferralLeadsList, Lead.OwnerId);
    List<User> users = REFERRAL_LEAD_REPO.getCCRMUsers(userIds);
    Set<Id> ccrmUserIds = ListUtil.getIds(users, User.Id);

    for (Lead referralRec : filteredReferralLeadsList) {
      if (!ccrmUserIds.contains(referralRec.OwnerId)) {
        continue;
      }
      InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
        referralNotificationId,
        referralRec.Id,
        referralRec.OwnerId,
        NOTIFICATION_TITLE,
        NOTIFICATION_BODY
      );
      CommonUtil.sendInAppNotification(notificationWrapper);
    }
  }

  /**
   * @description publish cloud events for Referral Leads
   * @param leads list of Lead Records
   * @param oldMap map of old lead records
   **/
  public static void publishCloudEvents(
    List<Lead> leads,
    Map<Id, Lead> oldMap
  ) {
    try {
      List<Lead> filteredReferralLeadList = ListUtil.filter(leads, oldMap)
        .notEquals(Lead.channel__c, CHANNEL_COMMERCIAL)
        .notEquals(Lead.channel__c, CHANNEL_PRIVATE_BANK)
        .changed(Lead.OwnerId)
        .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
        .equals(Lead.RecordTypeId, RTLead.referralLead)
        .equals(
          Lead.Referral_Status__c,
          new List<String>{ REFERRAL_STATUS_NEW, REFERRAL_STATUS_IN_PROGRESS }
        )
        .toList();

      List<CloudEventModel> cloudEvents = ReferralCloudEventModelController.createCloudEvents(
        filteredReferralLeadList
      );
      CloudEventController.publishCloudEvents(cloudEvents);
    } catch (Exception e) {
      Logger.info(
          'Errored out while publishing the cloud event when the Referral Owner changes',
          e
        )
        .save();
      throw e;
    }
  }

  /**
   * @description This is used to update the status of parent Lead Outcome to 'Referred'
   * @name updateParentLead
   * @param records List of new records
   */
  public static void updateParentLead(List<Lead> records) {
    try {
      List<Lead> filteredReferralLeadsList = ListUtil.filter(records)
        .isNotNull(Lead.Referrer_Lead__c)
        .toList();

      Set<Id> parentLeadsIdsSet = ListUtil.getIds(
        filteredReferralLeadsList,
        Lead.Referrer_Lead__c
      );

      List<Lead> parentLeadsList = REFERRAL_LEAD_REPO.fetchParentLeads(
        parentLeadsIdsSet
      );
      ListUtil.setField(
        parentLeadsList,
        Lead.Lead_Outcome__c,
        LEAD_OUTCOME_REFERRED
      );
      DML_REPO.doUpdate(parentLeadsList);
    } catch (Exception e) {
      Logger.error('Error occured while updating lead status and outcome', e)
        .save();
    }
  }

  /**
   * @description This is used to map Customer Need from Referral Customer Need
   * @name mapReferralCustomerNeed
   * @param records List of new records
   */
  public static void mapReferralCustomerNeed(List<Lead> records) {
    try {
      List<Lead> filterLeadList = ListUtil.filter(records)
        .isNotNull(Lead.Referral_Customer_Needs__c)
        .isNull(Lead.FinServ__ExpressedInterest__c)
        .toList();

      updateCustomerNeed(filterLeadList);
    } catch (Exception e) {
      Logger.info(
          'Unable to populate the customer needs based on Referral customer needs value',
          e
        )
        .save();
    }
  }

  /**
   * @description updateCustomerNeed update Customer Need value
   * @param leadList lead records
   */
  private static void updateCustomerNeed(List<Lead> leadList) {
    for (Lead record : leadList) {
      String key = CCRM + record.Referral_Customer_Needs__c;
      record.FinServ__ExpressedInterest__c = QueryReferralCustomerNeedMapping.get(
          key
        )
        ?.Customer_Need__c;
    }
  }

  /**
   * @description This is used to map Internal referrer as current user
   * @name setDefaultInternalReferrer
   * @param records List of new records
   */
  public static void setDefaultInternalReferrer(List<Lead> records) {
    ListUtil.setFieldIfNull(
      records,
      Lead.FinServ__ReferredByUser__c,
      UserInfo.getUserId()
    );
  }

  /**
   * @description This is used to map Internal referrer as current user
   * @name populateNewToBank
   * @param records List of new records
   * @param oldMap map of old records
   */
  public static void populateNewToBank(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      List<Lead> filteredRefList = ListUtil.filter(records, oldMap)
        .changed(Lead.FinServ__RelatedAccount__c)
        .toList();

      Set<Id> accountIdsSet = ListUtil.getIds(
        filteredRefList,
        Lead.FinServ__RelatedAccount__c
      );

      List<Account> prospectAccountList = REFERRAL_LEAD_REPO.getAccountRecords(
        accountIdsSet
      );

      Set<Id> prospectAccountIdsSet = ListUtil.getIds(
        prospectAccountList,
        Account.Id
      );

      setNewToBank(filteredRefList, prospectAccountIdsSet);
    } catch (Exception e) {
      Logger.info('Unable to set the New to Bank flag on referral Lead ', e)
        .save();
    }
  }

  /**
   * @description This method updates New_to_Bank__c flag
   * @param filteredRefList List of lead records
   * @param prospectAccountIdsSet Set of prospect customer Ids
   */
  @testVisible
  private static void setNewToBank(
    List<Lead> filteredRefList,
    Set<Id> prospectAccountIdsSet
  ) {
    for (Lead refLead : filteredRefList) {
      refLead.New_to_Bank__c = String.isBlank(
          refLead.FinServ__RelatedAccount__c
        ) || prospectAccountIdsSet.contains(refLead.FinServ__RelatedAccount__c)
        ? 'Yes'
        : 'No';
    }
  }

  /**
   * @description This method truncate leading zeros from Phone numbers
   * @param records List of Referral records
   */
  public static void updateContactInfo(List<Lead> records) {
    List<Lead> filteredRefList = ListUtil.filter(records)
      .equals(Lead.Referral_Status__c, REFERRAL_STATUS_NEW)
      .isNotNull(Lead.External_Id__c)
      .anyNotNull(CONTACT_INFO_FIELDS)
      .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
      .toList();

    for (Lead refRec : filteredRefList) {
      refRec.MobilePhone = sanitizeContactValue(refRec.MobilePhone);
      refRec.Work_Phone__c = sanitizeContactValue(refRec.Work_Phone__c);
      refRec.Home_Phone__c = sanitizeContactValue(refRec.Home_Phone__c);
    }
  }

  /**
   * @description this is used to santise the contact method
   * @param contactValue value of contact method
   * @return String that contains santized contact method value
   */
  @TestVisible
  private static String sanitizeContactValue(String contactValue) {
    if (contactValue == null) {
      return null;
    }
    return contactValue.replaceFirst('^\\+610', '+61');
  }
}
