/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMUserTerritorySetupActions is class to handle onboarding of user and creating/updating user territory record.
 */
public with sharing class MLCRMUserTerritorySetupActions {
  /**
   * @description Salesforce Automation for Onboarding MLCRM User
   * @name subscribeUserRecord
   * @param records new list of platform event records
   * @author Ashish Kumar
   * @US CC-4820
   */
  public static void subscribeUserRecord(
    List<User_Territory_Setup_Event__e> records
  ) {
    try {
      Set<String> setOfUserId = new Set<String>();
      Set<String> setOfTerritoryName = new Set<String>();
      Map<String, String> mapOfTerritory = new Map<String, String>();
      for (User_Territory_Setup_Event__e objEvent : records) {
        if (objEvent.User_Id__c != null) {
          setOfUserId.addAll(new Set<String>(objEvent.User_Id__c.split(';')));
        }
      }

      if (!setOfUserId.isEmpty()) {
        List<User> lstOfUsers = [
          SELECT Id, ML_Territories__c, ML_Role__c, IsActive
          FROM User
          WHERE ID IN :setOfUserId
        ];
        for (User objUser : lstOfUsers) {
          if (objUser.ML_Territories__c != null) {
            setOfTerritoryName.addAll(objUser.ML_Territories__c.split(';'));
          }
        }
        List<Territory__c> lstOfTerritory = [
          SELECT Id, Name
          FROM Territory__c
          WHERE Name IN :setOfTerritoryName
        ];
        Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
        for (User_Territory__c objUT : [
          SELECT
            Id,
            User__c,
            Territory__c,
            Status__c,
            ML_Role__c,
            Territory__r.Name
          FROM User_Territory__c
          WHERE User__c IN :setOfUserId
        ]) {
          if (!mapOfUserTerritory.containsKey(objUT.User__c)) {
            mapOfUserTerritory.put(
              objUT.User__c,
              new List<User_Territory__c>()
            );
          }
          mapOfUserTerritory.get(objUT.User__c).add(objUT);
        }
        for (Territory__c objTerritory : lstOfTerritory) {
          mapOfTerritory.put(objTerritory.Name, objTerritory.Id);
        }
        List<User_Territory__c> lstOfUserTerritory = setUpTerritoryForUsers(
          lstOfUsers,
          mapOfUserTerritory,
          mapOfTerritory
        );
        if (lstOfUserTerritory != null && !lstOfUserTerritory.isEmpty()) {
          List<Database.UpsertResult> lstOfSaveResult = Database.upsert(
            lstOfUserTerritory,
            false
          );
          for (Database.upsertResult result : lstOfSaveResult) {
            if (!result.isSuccess()) {
              Logger.error('Error occured while onboarding user', result);
              Logger.saveLog();
            }
          }
        }
      }
    } catch (Exception ex) {
      //log errors to application log
      Logger.error('Error occured while onboarding user', ex);
      Logger.saveLog();
    }
  }

  private static List<User_Territory__c> setUpTerritoryForUsers(
    List<User> lstOfUsers,
    Map<Id, List<User_Territory__c>> mapOfUserTerritory,
    Map<String, String> mapOfTerritory
  ) {
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    Set<String> setOfTerritory = new Set<String>();
    List<User> lstOfInActiveUserToUpdate = new List<User>();
    for (User objUser : lstOfUsers) {
      if (objUser.ML_Territories__c != null) {
        setOfTerritory = new Set<String>(objUser.ML_Territories__c.split(';'));
      }
      if (objUser.isActive == false) {
        objUser.ML_Territories__c = null;
        objUser.ML_Role__c = null;
        lstOfInActiveUserToUpdate.add(objUser);
      }

      //new user scenerio
      if (!mapOfUserTerritory.containsKey(objUser.Id)) {
        for (String eachTerritory : setOfTerritory) {
          User_Territory__c objTerritory = new User_Territory__c();
          objTerritory.User__c = objUser.Id;
          objTerritory.Status__c = MLCRMConstants.STATUS_ACTIVE;
          objTerritory.ML_Role__c = objUser.ML_Role__c;
          objTerritory.Territory__c = mapOfTerritory.get(eachTerritory);
          lstOfUserTerritory.add(objTerritory);
        }
      } else if (
        mapOfUserTerritory.containsKey(objUser.Id) &&
        (objUser.IsActive == false ||
        objUser.ML_Territories__c == null ||
        objUser.ML_Role__c == null)
      ) {
        // existing/update user scenerio and user is deactivated
        for (
          User_Territory__c eachTerritory : mapOfUserTerritory.get(objUser.Id)
        ) {
          eachTerritory.Status__c = MLCRMConstants.INACTIVE_STATUS;
          lstOfUserTerritory.add(eachTerritory);
        }
      } else if (
        mapOfUserTerritory.containsKey(objUser.Id) && objUser.IsActive
      ) {
        // existing/update user scenerio
        for (
          User_Territory__c eachTerritory : mapOfUserTerritory.get(objUser.Id)
        ) {
          if (setOfTerritory.contains(eachTerritory.Territory__r.Name)) {
            eachTerritory.ML_Role__c = objUser.ML_Role__c;
            eachTerritory.Status__c = MLCRMConstants.STATUS_ACTIVE;
            // remove the existing territory from the set
            setOfTerritory.remove(eachTerritory.Territory__r.Name);
          } else {
            eachTerritory.ML_Role__c = objUser.ML_Role__c;
            eachTerritory.Status__c = MLCRMConstants.INACTIVE_STATUS;
          }
          lstOfUserTerritory.add(eachTerritory);
        }
      }

      // creating new territory records that does not exists for the user
      if (
        !setOfTerritory.isEmpty() &&
        mapOfUserTerritory.containsKey(objUser.Id) &&
        objUser.IsActive
      ) {
        for (String eachTerritory : setOfTerritory) {
          User_Territory__c objTerritory = new User_Territory__c();
          objTerritory.User__c = objUser.Id;
          objTerritory.Status__c = MLCRMConstants.STATUS_ACTIVE;
          objTerritory.ML_Role__c = objUser.ML_Role__c;
          objTerritory.Territory__c = mapOfTerritory.get(eachTerritory);
          lstOfUserTerritory.add(objTerritory);
        }
      }
    }
    if (!lstOfInActiveUserToUpdate.isEmpty()) {
      update lstOfInActiveUserToUpdate;
    }
    return lstOfUserTerritory;
  }
}
