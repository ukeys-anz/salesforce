/**
 * @author       : Ayushi Gupta
 * @since        : June 2025
 * @description  : This is the action class for CommercialOppTeamMemberTriggerHandler
 **/
public with sharing class CommercialOppTeamMemberActions {
  private static final CommercialOppTeamMemberRepository OPPTEAMMEMBER_REPOSITORY = (CommercialOppTeamMemberRepository) Lib_InstanceProvider.forType(
    CommercialOppTeamMemberRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description create app forms share records
   * @param records list of opp team member records
   */
  public static void createAppFormShareRecords(
    List<OpportunityTeamMember> records
  ) {
    try {
      Set<Id> oppTeamMemberIdsSet = (new Map<Id, SObject>(records)).keySet();
      //getting all those opp team members related to commercial opportunity
      List<OpportunityTeamMember> filteredRecords = OPPTEAMMEMBER_REPOSITORY.getOppTeamMembersRelatedToCommercialOpp(
        oppTeamMemberIdsSet
      );

      Map<Id, List<OpportunityTeamMember>> oppIdToOppTeamMembersMap = getOppIdToTeamMembersMap(
        filteredRecords
      );

      Set<Id> oppIds = ListUtil.getIds(
        filteredRecords,
        OpportunityTeamMember.OpportunityId
      );
      List<ApplicationForm> appForms = OPPTEAMMEMBER_REPOSITORY.getAppFormsRelatedToCommercialOpp(
        oppIds
      );
      List<ApplicationFormShare> appFormsShareList = createAppFormsShare(
        appForms,
        oppIdToOppTeamMembersMap
      );

      DML_REPOSITORY.doInsert(
        appFormsShareList,
        new DmlConfig().withoutSharing()
      );
    } catch (Exception e) {
      Logger.error(
          'Error while creating app form share records on insertion of opp team member',
          e
        )
        .save();
    }
  }

  /**
   * @description get opp Id and team members map
   * @param filteredRecords list of opp team member records
   * @return Map<Id, List<OpportunityTeamMember>>
   */
  private static Map<Id, List<OpportunityTeamMember>> getOppIdToTeamMembersMap(
    List<OpportunityTeamMember> filteredRecords
  ) {
    Map<Id, List<OpportunityTeamMember>> oppIdToOppTeamMembersMap = new Map<Id, List<OpportunityTeamMember>>();
    //can't use group by as it will fail if only one team member is added
    for (OpportunityTeamMember member : filteredRecords) {
      if (!oppIdToOppTeamMembersMap.containsKey(member.OpportunityId)) {
        oppIdToOppTeamMembersMap.put(
          member.OpportunityId,
          new List<OpportunityTeamMember>()
        );
      }
      oppIdToOppTeamMembersMap.get(member.OpportunityId).add(member);
    }
    return oppIdToOppTeamMembersMap;
  }
  /**
   * @description creates app form share records
   * @param appForms list of app forms records
   * @param oppIdToOppTeamMembersMap opp Id to opp team members map
   * @return List<ApplicationFormShare>
   */
  public static List<ApplicationFormShare> createAppFormsShare(
    List<ApplicationForm> appForms,
    Map<Id, List<OpportunityTeamMember>> oppIdToOppTeamMembersMap
  ) {
    List<ApplicationFormShare> appFormsShareList = new List<ApplicationFormShare>();
    for (ApplicationForm appForm : appForms) {
      List<OpportunityTeamMember> oppTeamMembers = oppIdToOppTeamMembersMap.get(
        appForm.OpportunityId
      ) ?? new List<OpportunityTeamMember>();
      for (OpportunityTeamMember member : oppTeamMembers) {
        ApplicationFormShare appFormShare = new ApplicationFormShare();
        appFormShare.parentId = appForm.Id;
        appFormShare.RowCause = 'Manual';
        appFormShare.accesslevel = 'Edit';
        appFormShare.UserOrGroupId = member.UserId;
        appFormsShareList.add(appFormShare);
      }
    }
    return appFormsShareList;
  }

  /**
   * @description deletes app forms share records
   * @param records list of opp team member records
   */
  public static void deleteAppFormShareRecords(
    List<OpportunityTeamMember> records
  ) {
    try {
      Set<Id> userIds = ListUtil.getIds(records, OpportunityTeamMember.UserId);
      List<ApplicationFormShare> appFormShares = OPPTEAMMEMBER_REPOSITORY.getAppFormShareRecords(
        userIds
      );
      DML_REPOSITORY.doDelete(appFormShares);
    } catch (Exception e) {
      Logger.error(
          'Error while deleting app form share records on deletion of opp team member',
          e
        )
        .save();
    }
  }
}
