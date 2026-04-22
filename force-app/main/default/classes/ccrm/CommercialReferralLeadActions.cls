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
  private static final String NOTIFICATION_BODY = 'A new Referral has been assigned to you.';
  private static final String CUSTOM_NOTIFICATION = 'Commercial_Referral_Notification';
  private static final String CHANNEL_PRIVATE_BANK = 'Private Bank';
  private static final String CHANNEL_COMMERCIAL = 'Commercial';
  private static final String LEAD_OUTCOME_REFERRED = 'Referred';
  private static final String CCRM = 'CCRM-';
  private static final String NO_CLG_FOR_RETAIL_REFERRALS_ERROR = 'CLG cannot be used for Retail Referrals. Please use an Individual or Business entity.';
  @testVisible
  private static final String REFERRAL_STATUS_EXPORT_FAILED = 'Export Failed';
  @testVisible
  private static final String ACCESS_LEVEL_EDIT = 'Edit';
  private static final String EXCESSIVE_LENGTH_ERROR = 'Error: Your note is too long';
  private static final Integer BYTE_SIZE_LIMIT = 3500;

  private static final Set<SobjectField> CONTACT_INFO_FIELDS = new Set<SObjectField>{
    Lead.Home_Phone__c,
    Lead.Work_Phone__c,
    Lead.MobilePhone
  };

  private static final String CUSTOM_PERMISSION_DEVELOPERNAME = 'Manage_Referrals_in_CRM';

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
      String referenceNumber = referralRec.Lead_Auto_Number__c;
      String notificationBody =
        'Referral Ref: ' +
        referenceNumber +
        '\n' +
        NOTIFICATION_BODY;
      InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
        referralNotificationId,
        referralRec.Id,
        referralRec.OwnerId,
        NOTIFICATION_TITLE,
        notificationBody
      );
      CommonUtil.sendInAppNotification(notificationWrapper);
    }
  }

  /**
   * @description validate notes on record save
   * @param records list of Lead Records
   * @param oldMap map of old lead records
   **/
  public static void validateNotesOnReferral(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> filteredReferralLeadList = ListUtil.filter(records, oldMap)
      .changed(Lead.Note__c)
      .isNotNull(Lead.Note__c)
      .toList();

    if (filteredReferralLeadList.isEmpty()) {
      return;
    }

    for (Lead eachLead : filteredReferralLeadList) {
      if (Blob.valueOf(eachLead.Note__c).size() > BYTE_SIZE_LIMIT) {
        eachLead.addError(EXCESSIVE_LENGTH_ERROR);
      }
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
        .changed(Lead.OwnerId)
        .notEqualsToField(Lead.OwnerId, Lead.FinServ__ReferredByUser__c)
        .equals(Lead.RecordTypeId, RTLead.referralLead)
        .equals(
          Lead.Referral_Status__c,
          new List<String>{ REFERRAL_STATUS_NEW, REFERRAL_STATUS_IN_PROGRESS }
        )
        .oldNotEquals(Lead.Referral_Status__c, REFERRAL_STATUS_EXPORT_FAILED)
        .toList();

      List<Lead> finalLeadsToPublish = filterLeadsByPermission(
        filteredReferralLeadList
      );

      List<CloudEventModel> cloudEvents = ReferralCloudEventModelController.createCloudEvents(
        finalLeadsToPublish
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
   * @description publish cloud events for Referral Leads for export failed referral status
   * @param leads list of Lead Records
   */
  public static void republishFailedEvents(List<Lead> leads) {
    List<Lead> exportFailedLeads = ListUtil.filter(leads)
      .equals(Lead.Referral_Status__c, REFERRAL_STATUS_EXPORT_FAILED)
      .toList();

    if (exportFailedLeads.isEmpty()) {
      return;
    }

    List<Lead> finalLeadsToPublish = filterLeadsByPermission(exportFailedLeads);

    List<CloudEventModel> cloudEvents = ReferralCloudEventModelController.createCloudEvents(
      finalLeadsToPublish
    );
    CloudEventController.publishCloudEvents(cloudEvents);
  }

  /**
   * @description This is used to process and publish cloud events for referral leads
   * @param filteredLeads List of filtered referral lead records
   * @return List<Lead> List of cloud events to be published
   */
  private static List<Lead> filterLeadsByPermission(List<Lead> filteredLeads) {
    Set<Id> leadOwnerIds = ListUtil.getIds(filteredLeads, Lead.OwnerId);

    Set<Id> ownersWithPermission = getListOfOwnerIdsHavingCustomPermission(
      leadOwnerIds,
      CUSTOM_PERMISSION_DEVELOPERNAME
    );

    List<Lead> finalLeadsToPublish = ListUtil.filter(filteredLeads)
      .notEquals(Lead.OwnerId, ownersWithPermission)
      .toList();

    return finalLeadsToPublish;
  }

  /**
   * @description This is used to get set of users having custom permission
   * @name getListOfOwnerIdsHavingCustomPermission
   * @param userIdSet Set of owner id of leads
   * @param customPermission String custom permission name
   * @return Set<Id> List of user Ids having custom permission assigned
   */
  public static Set<Id> getListOfOwnerIdsHavingCustomPermission(
    Set<Id> userIdSet,
    String customPermission
  ) {
    List<SetupEntityAccess> listSetupEntityAccess = REFERRAL_LEAD_REPO.getPermissionSetWithCustomPermission(
      customPermission
    );

    Set<Id> permissionSetWithCustomPermission = ListUtil.getIds(
      listSetupEntityAccess,
      SetupEntityAccess.ParentId
    );
    List<PermissionSetGroupComponent> listPermissionSetGroupComponent = REFERRAL_LEAD_REPO.getPermissionSetGroupFromPS(
      permissionSetWithCustomPermission
    );

    Set<Id> permissionSetGroupFromPS = ListUtil.getIds(
      listPermissionSetGroupComponent,
      PermissionSetGroupComponent.PermissionSetGroupId
    );
    List<PermissionSetAssignment> listPermissionSetAssignment = REFERRAL_LEAD_REPO.listOfUsersHavingCustomPermission(
      userIdSet,
      permissionSetWithCustomPermission,
      permissionSetGroupFromPS
    );

    Set<Id> setOfOwnerIdsHavingCustomPermission = ListUtil.getIds(
      listPermissionSetAssignment,
      PermissionSetAssignment.AssigneeId
    );

    return setOfOwnerIdsHavingCustomPermission;
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

  /**
   * @description this is used restrict CLG Existing customer for retail referrals
   * @param newReferrals new referrals from Trigger.new
   * @param oldReferrals old referral map from Trigger.oldMap
   */
  public static void restrictCLGExistingCustomerForRetailReferrals(
    List<Lead> newReferrals,
    Map<Id, Lead> oldReferrals
  ) {
    List<Lead> referralsWithExistingCustomers = ListUtil.filter(
        newReferrals,
        oldReferrals
      )
      .changed(Lead.Finserv__RelatedAccount__c)
      .isNotNull(Lead.FinServ__RelatedAccount__c)
      .notEquals(
        Lead.Channel__c,
        new Set<String>{ CHANNEL_COMMERCIAL, CHANNEL_PRIVATE_BANK }
      )
      .toList();
    Set<Id> existingCustomerIds = ListUtil.getIds(
      referralsWithExistingCustomers,
      Lead.FinServ__RelatedAccount__c
    );
    List<Account> existingCustomers = REFERRAL_LEAD_REPO.getCustomers(
      existingCustomerIds
    );
    List<Account> existingCLGCustomers = ListUtil.filter(existingCustomers)
      .equals(Lead.RecordTypeId, RTAccount.clgAccount)
      .toList();

    Map<Id, Account> existingCLGCustomersById = (Map<Id, Account>) ListUtil.mapBy(
      existingCLGCustomers,
      Lead.Id
    );

    for (Lead referral : referralsWithExistingCustomers) {
      if (
        existingCLGCustomersById.containsKey(
          referral.FinServ__RelatedAccount__c
        )
      ) {
        referral.addError(NO_CLG_FOR_RETAIL_REFERRALS_ERROR);
      }
    }
  }

  /**
   * @description This is used to share the record when referral status changes
   * @name shareExportFailedRef
   * @param records List of lead records
   * @param oldMap Map of old lead records
   */
  public static void shareExportFailedRef(
    List<Lead> records,
    Map<Id, Lead> oldMap
  ) {
    try {
      List<Lead> filteredLeadList = ListUtil.filter(records, oldMap)
        .changed(Lead.Referral_Status__c)
        .toList();

      Set<Id> leadIdsSet = ListUtil.getIds(filteredLeadList, Lead.Id);

      Set<Id> intRefIdsSet = ListUtil.getIds(
        filteredLeadList,
        Lead.FinServ__ReferredByUser__c
      );

      List<LeadShare> existingleadShareList = REFERRAL_LEAD_REPO.getExistingLeadShare(
        leadIdsSet,
        intRefIdsSet
      );

      Map<Id, List<LeadShare>> leadIdToLeadShareListMap = (Map<Id, List<LeadShare>>) Listutil.GroupBy(
        existingleadShareList,
        LeadShare.LeadId
      );

      List<LeadShare> leadShareList = formLeadShareList(
        filteredLeadList,
        leadIdToLeadShareListMap
      );

      if (leadShareList.isEmpty()) {
        return;
      }
      DML_REPO.doUpsert(leadShareList, new DmlConfig().withoutSharing());
    } catch (Exception e) {
      Logger.error(
          'Error while inserting the Lead share record during export failed.',
          e
        )
        .save();
    }
  }

  /**
   * @description This is used to form a list of lead share record that need to be upsert
   * @param filteredLeadList List of lead list
   * @param leadIdToLeadShareListMap Map of Lead Id and List of lead share records
   * @return List<LeadShare> List of lead share records
   */
  private static List<LeadShare> formLeadShareList(
    List<Lead> filteredLeadList,
    Map<Id, List<LeadShare>> leadIdToLeadShareListMap
  ) {
    List<LeadShare> leadShareList = new List<LeadShare>();
    for (Lead leadRec : filteredLeadList) {
      LeadShare leadShare;
      List<LeadShare> lsList = leadIdToLeadShareListMap.get(leadRec.Id);
      for (LeadShare lsRec : lsList) {
        if (lsRec.UserOrGroupId == leadRec.FinServ__ReferredByUser__c) {
          leadShare = lsRec;
          leadShare.LeadAccessLevel = (leadRec.Referral_Status__c ==
            REFERRAL_STATUS_EXPORT_FAILED)
            ? ACCESS_LEVEL_EDIT
            : REFERRAL_LEAD_ACCESS;
          leadShareList.add(leadShare);
          break;
        }
      }
      if (leadShare != null) {
        continue;
      }
      leadShare = new LeadShare();
      leadShare.LeadId = leadRec.Id;
      leadShare.RowCause = 'Manual';
      leadShare.LeadAccessLevel = (leadRec.Referral_Status__c ==
        REFERRAL_STATUS_EXPORT_FAILED)
        ? ACCESS_LEVEL_EDIT
        : REFERRAL_LEAD_ACCESS;
      leadShare.UserOrGroupId = leadRec.FinServ__ReferredByUser__c;
      leadShareList.add(leadShare);
    }
    return leadShareList;
  }
}
