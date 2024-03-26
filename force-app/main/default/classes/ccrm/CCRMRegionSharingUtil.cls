/**
 * @author Tan Phan
 * @since  07/2022
 * @group CCRM (Commercial CRM)
 * @description Utility class to handle add/remove users and records from regions (public group). Create new public groups if region doesn't exist yet.
 * PMD.ApexCRUDViolation suppressed: this class handles Apex managed sharing so it may need more object/field permissions than what the running users have
 * PMD.CognitiveComplexity, PMD.CyclomaticComplexity suppressed: this class handles check and create public group, add/remove users and non-setup records to the group, the complexity is higher than expected
 * without sharing: this class handles Apex managed sharing so it may need more record visibility permissions than what the running users have
 */
@SuppressWarnings(
  'PMD.ApexCRUDViolation, PMD.CognitiveComplexity, PMD.CyclomaticComplexity'
)
public without sharing class CCRMRegionSharingUtil {
  /**
   * @description Store map of public group developer name to public group ID
   */
  private static Map<String, Id> mapRegions;

  /**
   * @description Initialize {@link mapRegions} in static constructor to be used in all public methods
   */
  static {
    mapRegions = new Map<String, Id>();
    for (Group g : [
      SELECT Id, DeveloperName
      FROM Group
      WHERE
        Type = 'Regular'
        AND (DeveloperName LIKE :CCRMConstants.BB_SEGMENT + '_%'
        OR DeveloperName LIKE :CCRMConstants.SBB_SEGMENT + '_%')
    ]) {
      mapRegions.put(g.DeveloperName, g.Id);
    }
  }

  /**
   * @description Trigger handler to share lead records to owner's region
   * @param records Lead records to sahre
   */
  public static void shareLeadsToOwnerRegion(List<Lead> records) {
    List<Lead> recordsToShare = new List<Lead>();
    for (Lead record : records) {
      if (record.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID) {
        recordsToShare.add(record);
      }
    }

    if (recordsToShare.isEmpty()) {
      return;
    }

    Map<String, Set<Id>> mapAreaCodeToRecordIds = CCRMRegionSharingUtil.groupRecordsByOwnerRegion(
      records,
      null
    );
    CCRMRegionSharingUtil.addRecordsToRegion(
      Lead.getSObjectType(),
      mapAreaCodeToRecordIds
    );
  }

  /**
   * @description Trigger handler to share opportunity records to owner's region
   * @param records Opportunity records to sahre
   */
  public static void shareOpportunitiesToOwnerRegion(
    List<Opportunity> records
  ) {
    List<Opportunity> recordsToShare = new List<Opportunity>();
    for (Opportunity record : records) {
      if (record.RecordTypeId == CCRMConstants.CCRM_OPP_RT_ID) {
        recordsToShare.add(record);
      }
    }

    if (recordsToShare.isEmpty()) {
      return;
    }

    Map<String, Set<Id>> mapAreaCodeToRecordIds = CCRMRegionSharingUtil.groupRecordsByOwnerRegion(
      records,
      null
    );
    CCRMRegionSharingUtil.addRecordsToRegion(
      Opportunity.getSObjectType(),
      mapAreaCodeToRecordIds
    );
  }

  /**
   * @description Trigger handler to share lead records to owner's region
   * @param newLeadList Updated lead record list
   * @param oldLeadMap old lead map
   */
  public static void shareLeadsToUpdatedOwnerRegion(
    List<Lead> newLeadList,
    Map<Id, Lead> oldLeadMap
  ) {
    LeadOpportunityAccessWrapper leadOpportunityAccessWrapperInst = new LeadOpportunityAccessWrapper();
    leadOpportunityAccessWrapperInst.transferRecordsAsync = new TransferRecordsQueueable();
    leadOpportunityAccessWrapperInst.usersToRemoveFromRegion = new List<User>();
    leadOpportunityAccessWrapperInst.usersToAddToRegion = new List<User>();
    leadOpportunityAccessWrapperInst.leadsToTransfer = new List<Lead>();
    Set<String> oldOwnerIdSet = new Set<String>();
    Set<String> newOwnerIdSet = new Set<String>();
    for (Lead leadIterator : newLeadList) {
      String oldOwnerId = oldLeadMap.get(leadIterator.Id).OwnerId;
      if (
        leadIterator.RecordTypeId == CCRMConstants.CCRM_LEAD_RT_ID &&
        leadIterator.OwnerId != oldOwnerId
      ) {
        leadOpportunityAccessWrapperInst.leadsToTransfer.add(leadIterator);
        oldOwnerIdSet.add(oldOwnerId);
        newOwnerIdSet.add(leadIterator.OwnerId);
      }
    }
    if (oldOwnerIdSet.isEmpty() && newOwnerIdSet.isEmpty()) {
      return;
    }
    for (User userIterator : [
      SELECT Id, Area_Code__c, Commercial_Segment__c
      FROM User
      WHERE
        IsActive = TRUE
        AND Area_Code__c != NULL
        AND (Id IN :oldOwnerIdSet
        OR Id IN :newOwnerIdSet)
        AND (Commercial_Segment__c = :CCRMConstants.SBB_SEGMENT
        OR Commercial_Segment__c = :CCRMConstants.BB_SEGMENT)
    ]) {
      if (oldOwnerIdSet.contains(userIterator.Id)) {
        leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.add(
          userIterator
        );
      } else if (newOwnerIdSet.contains(userIterator.Id)) {
        leadOpportunityAccessWrapperInst.usersToAddToRegion.add(userIterator);
      }
    }
    if (!leadOpportunityAccessWrapperInst.leadsToTransfer.isEmpty()) {
      if (!leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.isEmpty()) {
        removeAndUpdateLeadAndOppoAccess(leadOpportunityAccessWrapperInst);
      }
      if (!leadOpportunityAccessWrapperInst.usersToAddToRegion.isEmpty()) {
        addLeadAndOpportunityAccessFromRegion(leadOpportunityAccessWrapperInst);
      }
      if (
        !leadOpportunityAccessWrapperInst.transferRecordsAsync.actions.isEmpty()
      ) {
        System.enqueueJob(
          leadOpportunityAccessWrapperInst.transferRecordsAsync
        );
      }
    }
  }

  /**
   * @description Trigger handler to share opportunity records to owner's region
   * @param newOppoList Updated Opportunity record list
   * @param oldOppoMap old Opportunity map
   */
  public static void shareOpportunityToUpdatedOwnerRegion(
    List<Opportunity> newOppoList,
    Map<Id, Opportunity> oldOppoMap
  ) {
    LeadOpportunityAccessWrapper leadOpportunityAccessWrapperInst = new LeadOpportunityAccessWrapper();
    leadOpportunityAccessWrapperInst.transferRecordsAsync = new TransferRecordsQueueable();
    leadOpportunityAccessWrapperInst.usersToRemoveFromRegion = new List<User>();
    leadOpportunityAccessWrapperInst.usersToAddToRegion = new List<User>();
    leadOpportunityAccessWrapperInst.opportunitiesToTransfer = new List<Opportunity>();
    Set<String> oldOwnerIdSet = new Set<String>();
    Set<String> newOwnerIdSet = new Set<String>();
    for (Opportunity oppoIterator : newOppoList) {
      String oldOwnerId = oldOppoMap.get(oppoIterator.Id).OwnerId;
      if (
        oppoIterator.RecordTypeId == CCRMConstants.CCRM_OPP_RT_ID &&
        oppoIterator.OwnerId != oldOwnerId
      ) {
        leadOpportunityAccessWrapperInst.opportunitiesToTransfer.add(
          oppoIterator
        );
        oldOwnerIdSet.add(oldOwnerId);
        newOwnerIdSet.add(oppoIterator.OwnerId);
      }
    }
    if (oldOwnerIdSet.isEmpty() && newOwnerIdSet.isEmpty()) {
      return;
    }
    for (User userIterator : [
      SELECT Id, Area_Code__c, Commercial_Segment__c
      FROM User
      WHERE
        IsActive = TRUE
        AND Area_Code__c != NULL
        AND (Id IN :oldOwnerIdSet
        OR Id IN :newOwnerIdSet)
        AND (Commercial_Segment__c = :CCRMConstants.SBB_SEGMENT
        OR Commercial_Segment__c = :CCRMConstants.BB_SEGMENT)
    ]) {
      if (oldOwnerIdSet.contains(userIterator.Id)) {
        leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.add(
          userIterator
        );
      } else if (newOwnerIdSet.contains(userIterator.Id)) {
        leadOpportunityAccessWrapperInst.usersToAddToRegion.add(userIterator);
      }
    }
    if (!leadOpportunityAccessWrapperInst.opportunitiesToTransfer.isEmpty()) {
      if (!leadOpportunityAccessWrapperInst.usersToAddToRegion.isEmpty()) {
        addLeadAndOpportunityAccessFromRegion(leadOpportunityAccessWrapperInst);
      }
      if (!leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.isEmpty()) {
        removeAndUpdateLeadAndOppoAccess(leadOpportunityAccessWrapperInst);
      }
      if (
        !leadOpportunityAccessWrapperInst.transferRecordsAsync.actions.isEmpty()
      ) {
        System.enqueueJob(
          leadOpportunityAccessWrapperInst.transferRecordsAsync
        );
      }
    }
  }

  /**
   * @description Check if user is switching to a different region. Then move active, owned leads/opps from old to new regions. Also move user region public group.
   * @param users User records to check for updated region.
   * @param mapOldUsers Old user records before updated. Grouped by user ID.
   */
  public static void updateUserRegion(
    List<User> users,
    Map<Id, User> mapOldUsers
  ) {
    LeadOpportunityAccessWrapper leadOpportunityAccessWrapperInst = new LeadOpportunityAccessWrapper();
    leadOpportunityAccessWrapperInst.usersToRemoveFromRegion = new List<User>();
    leadOpportunityAccessWrapperInst.usersToAddToRegion = new List<User>();
    Set<Id> ownerIdsToTransferRecords = new Set<Id>();
    for (User newUser : users) {
      User oldUser = mapOldUsers.get(newUser.Id);
      if (
        newUser.IsActive &&
        (newUser.Area_Code__c != oldUser.Area_Code__c ||
        newUser.Commercial_Segment__c != oldUser.Commercial_Segment__c)
      ) {
        ownerIdsToTransferRecords.add(newUser.ID);
        if (!String.isBlank(newUser.Area_Code__c)) {
          leadOpportunityAccessWrapperInst.usersToAddToRegion.add(newUser);
        }
        if (
          !String.isBlank(oldUser.Area_Code__c) &&
          getRegionId(oldUser.Commercial_Segment__c, oldUser.Area_Code__c) !=
          null
        ) {
          leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.add(oldUser);
        }
      }
    }
    if (
      leadOpportunityAccessWrapperInst.usersToAddToRegion.isEmpty() &&
      leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.isEmpty()
    ) {
      return;
    }

    leadOpportunityAccessWrapperInst.leadsToTransfer = [
      SELECT Id, OwnerId
      FROM Lead
      WHERE
        IsConverted = FALSE
        AND RecordTypeId = :CCRMConstants.CCRM_LEAD_RT_ID
        AND OwnerId IN :ownerIdsToTransferRecords
    ];
    leadOpportunityAccessWrapperInst.opportunitiesToTransfer = [
      SELECT Id, OwnerId
      FROM Opportunity
      WHERE
        IsClosed = FALSE
        AND RecordTypeId = :CCRMConstants.CCRM_OPP_RT_ID
        AND OwnerId IN :ownerIdsToTransferRecords
    ];

    leadOpportunityAccessWrapperInst.transferRecordsAsync = new TransferRecordsQueueable();

    if (!leadOpportunityAccessWrapperInst.usersToRemoveFromRegion.isEmpty()) {
      removeUsersFromRegion(
        leadOpportunityAccessWrapperInst.usersToRemoveFromRegion
      );
      removeAndUpdateLeadAndOppoAccess(leadOpportunityAccessWrapperInst);
    }

    if (!leadOpportunityAccessWrapperInst.usersToAddToRegion.isEmpty()) {
      addUsersToRegion(leadOpportunityAccessWrapperInst.usersToAddToRegion);
      addLeadAndOpportunityAccessFromRegion(leadOpportunityAccessWrapperInst);
    }

    if (
      !leadOpportunityAccessWrapperInst.transferRecordsAsync.actions.isEmpty()
    ) {
      System.enqueueJob(leadOpportunityAccessWrapperInst.transferRecordsAsync);
    }
  }

  /**
   * @description Remove access record for lead and Opportunity when users moves to a new region or on ownership change
   * * @param leadOpportunityAccessWrapperInst LeadOpportunityAccessWrapper isnatnce to pass lead, opportunity and user list to update
   */
  private static void removeAndUpdateLeadAndOppoAccess(
    LeadOpportunityAccessWrapper leadOpportunityAccessWrapperInst
  ) {
    if (
      leadOpportunityAccessWrapperInst.leadsToTransfer != null &&
      !leadOpportunityAccessWrapperInst.leadsToTransfer.isEmpty()
    ) {
      leadOpportunityAccessWrapperInst.transferRecordsAsync.appendAction(
        false,
        Lead.getSObjectType(),
        groupRecordsByOwnerRegion(
          leadOpportunityAccessWrapperInst.leadsToTransfer,
          leadOpportunityAccessWrapperInst.usersToRemoveFromRegion
        )
      );
    }
    if (
      leadOpportunityAccessWrapperInst.opportunitiesToTransfer != null &&
      !leadOpportunityAccessWrapperInst.opportunitiesToTransfer.isEmpty()
    ) {
      leadOpportunityAccessWrapperInst.transferRecordsAsync.appendAction(
        false,
        Opportunity.getSObjectType(),
        groupRecordsByOwnerRegion(
          leadOpportunityAccessWrapperInst.opportunitiesToTransfer,
          leadOpportunityAccessWrapperInst.usersToRemoveFromRegion
        )
      );
    }
  }

  /**
   * @description Remove access record for lead and Opportunity when users moves to a new region or on ownership change
   * * @param leadOpportunityAccessWrapperInst LeadOpportunityAccessWrapper isnatnce to pass lead, opportunity and user list to update
   */
  private static void addLeadAndOpportunityAccessFromRegion(
    LeadOpportunityAccessWrapper leadOpportunityAccessWrapperInst
  ) {
    if (
      leadOpportunityAccessWrapperInst.leadsToTransfer != null &&
      !leadOpportunityAccessWrapperInst.leadsToTransfer.isEmpty()
    ) {
      leadOpportunityAccessWrapperInst.transferRecordsAsync.appendAction(
        true,
        Lead.getSObjectType(),
        groupRecordsByOwnerRegion(
          leadOpportunityAccessWrapperInst.leadsToTransfer,
          leadOpportunityAccessWrapperInst.usersToAddToRegion
        )
      );
    }
    if (
      leadOpportunityAccessWrapperInst.opportunitiesToTransfer != null &&
      !leadOpportunityAccessWrapperInst.opportunitiesToTransfer.isEmpty()
    ) {
      leadOpportunityAccessWrapperInst.transferRecordsAsync.appendAction(
        true,
        Opportunity.getSObjectType(),
        groupRecordsByOwnerRegion(
          leadOpportunityAccessWrapperInst.opportunitiesToTransfer,
          leadOpportunityAccessWrapperInst.usersToAddToRegion
        )
      );
    }
  }

  /**
   * @description Share a list of records to their owners' regions. ALL RECORDS must be of the SAME SOBJECT
   * @param records The list of records to be grouped
   * @param owners (Optional) If available, pass the list of owner records (must contains Area_Code__c fields)
   * @return `Map<String, Set<Id>>` map of records grouped by area code
   */
  @TestVisible
  private static Map<String, Set<Id>> groupRecordsByOwnerRegion(
    List<SObject> records,
    List<User> owners
  ) {
    Map<Id, User> mapOwners;

    if (owners != null && !owners.isEmpty()) {
      mapOwners = new Map<Id, User>(owners);
    } else {
      Set<Id> ownerIds = new Set<Id>();
      for (SObject record : records) {
        ownerIds.add((Id) record.get('OwnerId'));
      }
      mapOwners = new Map<Id, User>(
        [
          SELECT Id, Area_Code__c, Commercial_Segment__c
          FROM User
          WHERE
            IsActive = TRUE
            AND Area_Code__c != NULL
            AND Id IN :ownerIds
            AND (Commercial_Segment__c = :CCRMConstants.SBB_SEGMENT
            OR Commercial_Segment__c = :CCRMConstants.BB_SEGMENT)
        ]
      );
    }

    Map<String, Set<Id>> mapAreaCodeToRecordIds = new Map<String, Set<Id>>();
    for (SObject record : records) {
      Id ownerId = (Id) record.get('OwnerId');
      String areaCode = mapOwners.get(ownerId)?.Area_Code__c;
      String segment = mapOwners.get(ownerId)?.Commercial_Segment__c;
      if (String.isBlank(areaCode) || String.isBlank(segment)) {
        continue;
      }
      if (mapAreaCodeToRecordIds.containsKey(segment + '_' + areaCode)) {
        mapAreaCodeToRecordIds.get(segment + '_' + areaCode).add(record.Id);
      } else {
        mapAreaCodeToRecordIds.put(
          segment + '_' + areaCode,
          new Set<Id>{ record.Id }
        );
      }
    }

    return mapAreaCodeToRecordIds;
  }

  /**
   * @description Share a list of records to their owners' regions. ALL RECORDS must be of the SAME SOBJECT
   * @param objectType SObjectType of the records being shared
   * @param mapAreaCodeToRecordIds ID of the records to share, grouped by area code
   */
  @TestVisible
  private static void addRecordsToRegion(
    SObjectType objectType,
    Map<String, Set<Id>> mapAreaCodeToRecordIds
  ) {
    ShareObjectInfo shareObjectInfo = new ShareObjectInfo(objectType);
    List<SObject> shareRecords = new List<SObject>();
    Map<String, Set<Id>> newMapAreaCodeToRecordIds = new Map<String, Set<Id>>();
    Set<String> newAreaCodes = new Set<String>();
    for (String areaCode : mapAreaCodeToRecordIds.keySet()) {
      Id regionId = getRegionId(areaCode.split('_')[0], areaCode.split('_')[1]);
      //if regionId isn't available, need to create new region public group from the Area Codes and add users/owner and the record to the new public group
      if (regionId == null) {
        newAreaCodes.add(areaCode.split('_')[1]);
        newMapAreaCodeToRecordIds.put(
          areaCode,
          new Set<Id>(mapAreaCodeToRecordIds.get(areaCode))
        );
        continue;
      }
      for (Id recordId : mapAreaCodeToRecordIds.get(areaCode)) {
        shareRecords.add(shareObjectInfo.newInstance(recordId, regionId));
      }
    }

    if (!shareRecords.isEmpty()) {
      Database.SaveResult[] results = Database.insert(shareRecords);

      Logger.error('', results);
      Logger.saveLog();
    }

    if (!newMapAreaCodeToRecordIds.isEmpty()) {
      createRegions(newMapAreaCodeToRecordIds.keySet());
      addRecordsToRegion(objectType, newMapAreaCodeToRecordIds);
    }
  }

  /**
   * @description Remove a list of records from their owners' regions. ALL RECORDS must be of the SAME SOBJECT
   * @param objectType SObjectType of the records being removed
   * @param mapAreaCodeToRecordIds ID of the records to share, grouped by area code
   */
  @TestVisible
  private static void removeRecordsFromRegion(
    SObjectType objectType,
    Map<String, Set<Id>> mapAreaCodeToRecordIds
  ) {
    Set<Id> regionIds = new Set<Id>();
    Set<Id> recordIds = new Set<Id>();
    for (String areaCode : mapAreaCodeToRecordIds.keySet()) {
      Id regionId = getRegionId(areaCode.split('_')[0], areaCode.split('_')[1]);
      if (regionId != null) {
        regionIds.add(regionId);
        recordIds.addAll(mapAreaCodeToRecordIds.get(areaCode));
      }
    }

    //get Share records
    ShareObjectInfo shareObjectInfo = new ShareObjectInfo(objectType);
    //a record should only be shared to 1 region public group,
    //so there's no need to cross-check with origin mapping of recordId <-> regionId
    String query = String.format(
      'SELECT Id ' +
        'FROM {0} ' +
        'WHERE {1} IN :recordIds ' +
        ' AND RowCause = \'Manual\' ' +
        ' AND {2} = \'Edit\' ' +
        ' AND UserOrGroupId IN :regionIds',
      new List<String>{
        shareObjectInfo.name,
        shareObjectInfo.recordIdField,
        shareObjectInfo.accessLevelField
      }
    );
    List<SObject> shareRecords = Database.query(query);

    if (!shareRecords.isEmpty()) {
      Database.DeleteResult[] results = Database.delete(shareRecords);

      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Add a list of users to region public groups based on their Area_Code__c value
   * @param records The users to add to region public groups
   */
  public static void addUsersToRegion(List<User> records) {
    List<GroupMember> groupMembers = new List<GroupMember>();
    Set<String> newAreaCodes = new Set<String>();
    for (User record : records) {
      if (
        String.isBlank(record.Area_Code__c) ||
        String.isBlank(record.Commercial_Segment__c) ||
        (!record.Commercial_Segment__c.equalsIgnoreCase(
          CCRMConstants.BB_SEGMENT
        ) &&
        !record.Commercial_Segment__c.equalsIgnoreCase(
          CCRMConstants.SBB_SEGMENT
        ))
      ) {
        continue;
      }
      Id regionId = getRegionId(
        record.Commercial_Segment__c,
        record.Area_Code__c
      );
      if (regionId != null) {
        groupMembers.add(
          new GroupMember(UserOrGroupId = record.Id, GroupId = regionId)
        );
      } else {
        newAreaCodes.add(
          record.Commercial_Segment__c + '_' + record.Area_Code__c
        );
      }
    }

    if (!groupMembers.isEmpty()) {
      Database.SaveResult[] results = Database.insert(groupMembers);

      Logger.error('', results);
      Logger.saveLog();
    }

    if (!newAreaCodes.isEmpty()) {
      createRegions(newAreaCodes);
    }
  }

  /**
   * @description Remove users from their current regions based on the Area_Code__c value
   * @param records The users to remove from region public groups
   */
  @TestVisible
  private static void removeUsersFromRegion(List<User> records) {
    Set<Id> regionIds = new Set<Id>();
    Map<Id, Id> mapUserIdToRegionId = new Map<Id, Id>();
    for (User record : records) {
      if (
        String.isBlank(record.Area_Code__c) ||
        String.isBlank(record.Commercial_Segment__c)
      ) {
        continue;
      }
      Id regionId = getRegionId(
        record.Commercial_Segment__c,
        record.Area_Code__c
      );
      if (regionId != null) {
        regionIds.add(regionId);
        mapUserIdToRegionId.put(record.Id, regionId);
      }
    }
    if (regionIds.isEmpty()) {
      return;
    }

    List<GroupMember> groupMembers = new List<GroupMember>();
    for (GroupMember member : [
      SELECT Id, UserOrGroupId, GroupId
      FROM GroupMember
      WHERE UserOrGroupId IN :records AND GroupId IN :regionIds
    ]) {
      if (mapUserIdToRegionId.get(member.UserOrGroupId) == member.GroupId) {
        groupMembers.add(member);
      }
    }

    if (!groupMembers.isEmpty()) {
      Database.DeleteResult[] results = Database.delete(groupMembers);
      Logger.error('', results);
      Logger.saveLog();
    }
  }

  /**
   * @description Find region public group ID based on an area code value
   * @param segment The segment to find public group ID
   * @param areaCode The area code to find region public group ID
   * @return `Id` ID of the public group matched with the provided are code
   */
  private static Id getRegionId(String segment, String areaCode) {
    return mapRegions.get(segment + '_' + getRegionKeyFromAreaCode(areaCode));
  }

  /**
   * @description Format an area code to a string that can be used for public group DeveloperName
   * @param areaCode The are code to be formatted
   * @return `String` Get/generate public group DeveloperName from provided area code
   */
  private static String getRegionKeyFromAreaCode(String areaCode) {
    String areaCodeFormatted = areaCode.replaceAll('[^a-zA-Z0-9]', '');
    return areaCodeFormatted.length() > 80
      ? areaCodeFormatted.substring(0, 79)
      : areaCodeFormatted;
  }

  /**
   * @description Create region Public Group using area code as name, then find all users with matched area code and add as group members
   * @param segmentAreaCodes Segment and Area codes to create new public groups
   */
  private static void createRegions(Set<String> segmentAreaCodes) {
    //build list of new public group to create
    List<Group> regions = new List<Group>();
    Set<String> areaCodeSet = new Set<String>();
    String areaCode = '';
    for (String segmentAreaCodeIterator : segmentAreaCodes) {
      areaCode = getRegionKeyFromAreaCode(
        segmentAreaCodeIterator.split('_')[1]
      );
      areaCodeSet.add(segmentAreaCodeIterator.split('_')[1]);
      regions.add(
        new Group(
          Name = segmentAreaCodeIterator.split('_')[0] +
            ' ' +
            (areaCode.length() > 36 ? areaCode.substring(0, 35) : areaCode),
          DeveloperName = segmentAreaCodeIterator.split('_')[0] +
            '_' +
            areaCode,
          Type = 'Regular',
          DoesIncludeBosses = false
        )
      );
    }

    //insert and log results
    Database.SaveResult[] regionSaveResults = Database.insert(regions);
    Logger.error('', regionSaveResults);
    Logger.saveLog();

    //append newly created public groups to the mapRegions for processing
    for (Group region : regions) {
      mapRegions.put(region.DeveloperName, region.Id);
    }

    //find existing users that have same area codes and add to the new public groups
    List<User> usersOfNewRegion = [
      SELECT Id, Area_Code__c, Commercial_Segment__c
      FROM User
      WHERE
        IsActive = TRUE
        AND Area_Code__c IN :areaCodeSet
        AND (Commercial_Segment__c = :CCRMConstants.SBB_SEGMENT
        OR Commercial_Segment__c = :CCRMConstants.BB_SEGMENT)
    ];
    if (!usersOfNewRegion.isEmpty()) {
      System.enqueueJob(new AddUsersToRegionQueueable(usersOfNewRegion));
    }
  }

  /**
   * @description Helper inner class to determine object and field API names of Share records
   */
  private class ShareObjectInfo {
    private SObjectType objectType { get; set; }
    private String name { get; set; }
    private String recordIdField { get; set; }
    private String accessLevelField { get; set; }

    /**
     * @description Constructor. Read object info and determine API name of the share objects and fields
     * @param objectType SObjectType of the object to be shared
     */
    private ShareObjectInfo(SObjectType objectType) {
      DescribeSObjectResult objectInfo = objectType.getDescribe();
      if (objectInfo.isCustom()) {
        name = objectInfo.Name.left(objectInfo.Name.length() - 1) + 'Share';
        this.recordIdField = 'ParentId';
        this.accessLevelField = 'AccessLevel';
      } else {
        name = objectInfo.Name + 'Share';
        this.recordIdField = objectInfo.Name + 'Id';
        this.accessLevelField = objectInfo.Name + 'AccessLevel';
      }
      this.objectType = Schema.getGlobalDescribe().get(name);
    }

    /**
     * @description Instantiate a Share record
     * @param recordId ID of the record to be shared
     * @param userOrGroupId ID of user or group to share the record with
     * @return SObject The share record
     */
    private SObject newInstance(Id recordId, Id userOrGroupId) {
      SObject shareRecord = this.objectType.newSObject();
      shareRecord.put(this.recordIdField, recordId);
      shareRecord.put('UserOrGroupId', userOrGroupId);
      shareRecord.put(this.accessLevelField, 'Edit');
      shareRecord.put('RowCause', 'Manual');

      return shareRecord;
    }
  }

  /**
   * @description Invoke {@link addUsersToRegion} asynchronously
   */
  public class AddUsersToRegionQueueable implements Queueable {
    private List<User> records;

    /**
     * @description Constructor
     * @param records User records to pass on to {@link addUsersToRegion}
     */
    public AddUsersToRegionQueueable(List<User> records) {
      this.records = records;
    }

    /**
     * @description Queueable execute method
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
      addUsersToRegion(this.records);
    }
  }

  /**
   * @description Perform a series of actions of adding records to region or removing records from region
   */
  public class TransferRecordsQueueable implements Queueable {
    private List<TransferRecordActionWrapper> actions;

    /**
     * @description Constructor
     */
    private TransferRecordsQueueable() {
      this.actions = new List<TransferRecordActionWrapper>();
    }

    /**
     * @description Put 'add records to regions'/'remove records from regions' actions into a queue to be processed asynchronously
     * @param isSharing Indicate whether to add or remove records to/from regions
     * @param objectType SObjectType of the records
     * @param mapAreaCodeToRecordIds ID of the records to share, grouped by area code
     */
    private void appendAction(
      Boolean isSharing,
      SObjectType objectType,
      Map<String, Set<Id>> mapAreaCodeToRecordIds
    ) {
      TransferRecordActionWrapper action = new TransferRecordActionWrapper();
      action.isSharing = isSharing;
      action.objectType = objectType;
      action.mapAreaCodeToRecordIds = mapAreaCodeToRecordIds;
      this.actions.add(action);
    }

    /**
     * @description Queueable execute method
     * @param context QueueableContext
     */
    public void execute(QueueableContext context) {
      for (TransferRecordActionWrapper action : this.actions) {
        if (!action.isSharing) {
          removeRecordsFromRegion(
            action.objectType,
            action.mapAreaCodeToRecordIds
          );
        } else {
          addRecordsToRegion(action.objectType, action.mapAreaCodeToRecordIds);
        }
      }
    }
  }

  /**
   * @description Wrapper class for queueing actions in AddRemoveUsersToRegionQueueable
   */
  private class LeadOpportunityAccessWrapper {
    private List<Lead> leadsToTransfer;
    private List<User> usersToAddToRegion;
    private List<User> usersToRemoveFromRegion;
    private List<Opportunity> opportunitiesToTransfer;
    private TransferRecordsQueueable transferRecordsAsync;
  }

  /**
   * @description Wrapper class for queueing actions in AddUsersToRegionQueueable
   */
  private class TransferRecordActionWrapper {
    private Boolean isSharing;
    private SObjectType objectType;
    private Map<String, Set<Id>> mapAreaCodeToRecordIds;
  }
}
