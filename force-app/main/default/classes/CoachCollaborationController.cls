/**
 * @author Sanskriti Routray
 * @since Dec 2024
 * @description Controller to generate the deep link to access macos
 */
public with sharing class CoachCollaborationController {
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CoachCollaborationController COACH_COLLAB_CONTROLLER = (CoachCollaborationController) Lib_InstanceProvider.forType(
    CoachCollaborationController.class
  );

  /**
   * @description The method is used to create a deeplink to mobile app.
   * @param objectApiName object api name from where method is called
   * @param recordId the record id
   * @return `String` deeplink url.
   */
  @AuraEnabled
  public static String fetchJWETokenFromFrig(
    String objectApiName,
    String recordId
  ) {
    try {
      SObject objRecord = INTERACTION_REPOSITORY.fetchOCVId(
        objectApiName,
        recordId
      );
      if (objRecord == null) {
        throw new IllegalArgumentException('Valid Record not found');
      }
      String ocvId = (String) objRecord.getSobject('Account').get('OCV_ID__c');

      StaffTokenRequestModel staffModel = COACH_COLLAB_CONTROLLER.getStaffRequestModelByOcvId(
        ocvId
      );

      String accessToken = AuthTokenCacheUtil.getStaffToken(staffModel);
      if (String.isBlank(accessToken)) {
        return '';
      }
      Logger.info(
        'MacOS app launch button has been clicked by ' +
          UserInfo.getUserName() +
          ' (Id: ' +
          UserInfo.getUserId() +
          ')'
      );
      Logger.saveLog();
      createTask(ocvId, recordId);
      return System.Label.Coach_Collaboration_Deeplink + accessToken;
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description The method is used to create a task if coach collablration call is sucessfull.
   * @param ocvId the ocv id of the customer
   * @param recordId the record for which task is created
   */
  @future
  public static void createTask(String ocvId, String recordId) {
    Account objAccount = INTERACTION_REPOSITORY.findAccountByOCVId(ocvId);
    Task newTask = new Task(
      Subject = 'Opened Coach Collaboration',
      Priority = 'Normal',
      WhatId = recordId,
      WhoId = objAccount.PersonContactId,
      Status = 'Completed',
      RecordTypeId = QueryRT.of(Task.SObjectType).getId('Coach_Connect')
    );
    DML_REPOSITORY.doInsert(newTask);
  }

  /**
   * @description returns the StaffTokenRequestModel.
   * @param ocvId the ocv id of the customer
   * @return `StaffTokenRequestModel`
   */
  public StaffTokenRequestModel getStaffRequestModelByOcvId(String ocvId) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = ocvId;
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.apiScopesRequested = 'Coach_Collaboration_ForgeV2';
    return staffModel;
  }
}
