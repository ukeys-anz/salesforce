/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description UserTerritorySetupActions is class to handle onboarding of user and creating/updating user territory record.
 */
public with sharing class UserTerritorySetupActions {
  private static final String STATUS_ACTIVE = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';

  private static final UserActionsRepository USER_ACTIONS_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
  private static final UserTerritoryActionsRepository USER_TERRITORY_ACTIONS_REPOSITORY = (UserTerritoryActionsRepository) Lib_InstanceProvider.forType(
    UserTerritoryActionsRepository.class
  );
  private static final TerritoryActionsRepository TERRITORY_ACTIONS_REPOSITORY = (TerritoryActionsRepository) Lib_InstanceProvider.forType(
    TerritoryActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final Set<SObjectField> USER_FIELDS = new Set<SObjectField>{
    User.ML_Territories__c,
    User.ML_Role__c
  };

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
      Set<String> setOfUserId = ListUtil.getStringsWithSplit(
        records,
        User_Territory_Setup_Event__e.User_Id__c,
        ';'
      );

      List<User> lstOfUsers = USER_ACTIONS_REPOSITORY.getUserbyUserIds(
        setOfUserId
      );

      updateInactiveUsers(lstOfUsers);

      Set<String> setOfTerritoryName = ListUtil.getStringsWithSplit(
        lstOfUsers,
        User.ML_Territories__c,
        ';'
      );

      List<User_Territory__c> userTerritories = USER_TERRITORY_ACTIONS_REPOSITORY.getTerritoriesbyUserIds(
        setOfUserId
      );
      Map<Id, List<User_Territory__c>> mapOfUserTerritory = (Map<Id, List<User_Territory__c>>) ListUtil.groupBy(
        userTerritories,
        User_Territory__c.User__c
      );
      List<Territory__c> territories = TERRITORY_ACTIONS_REPOSITORY.getTerritoriesbyTerritoryNames(
        setOfTerritoryName
      );
      Map<String, Territory__c> mapOfTerritory = (Map<String, Territory__c>) ListUtil.mapBy(
        territories,
        Territory__c.Name
      );
      List<User_Territory__c> lstOfUserTerritory = setUpTerritoryForInActiveUsers(
        lstOfUsers,
        mapOfUserTerritory
      );
      lstOfUserTerritory.addAll(
        setUpTerritoryForNewUsers(
          lstOfUsers,
          mapOfUserTerritory,
          mapOfTerritory
        )
      );
      lstOfUserTerritory.addAll(
        setUpTerritoryForActiveUsers(
          lstOfUsers,
          mapOfUserTerritory,
          mapOfTerritory
        )
      );
      DML_REPOSITORY.doUpsert(lstOfUserTerritory, new DMLConfig().systemMode());
    } catch (Exception ex) {
      //log errors to application log
      Logger.error('Error occured while onboarding user', ex);
      Logger.saveLog();
    }
  }

  /**
   * @description update Inactive User
   * @name updateInactiveUsers
   * @param lstOfUsers List<User>
   */
  @TestVisible
  private static void updateInactiveUsers(List<User> lstOfUsers) {
    List<User> inActiveUsers = ListUtil.filter(lstOfUsers)
      .equals(User.isActive, false)
      .toList();
    ListUtil.setField(inActiveUsers, USER_FIELDS, null);
    DML_REPOSITORY.doUpdate(inActiveUsers, new DmlConfig().systemMode());
  }

  /**
   * @description set up Territory for Users
   * @name setUpTerritoryForUsers
   * @param lstOfUsers List of Users
   * @param mapOfUserTerritory Map<Id, List<User_Territory__c>>
   * @param mapOfTerritory Map<String, Territory__c>
   * @return List<User_Territory__c>
   */
  @TestVisible
  private static List<User_Territory__c> setUpTerritoryForNewUsers(
    List<User> lstOfUsers,
    Map<Id, List<User_Territory__c>> mapOfUserTerritory,
    Map<String, Territory__c> mapOfTerritory
  ) {
    List<User> newUsers = ListUtil.filter(lstOfUsers)
      .notEquals(User.Id, mapOfUserTerritory.keySet())
      .toList();
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    for (User objUser : newUsers) {
      Set<String> setOfTerritory = new Set<String>(
        objUser.ML_Territories__c.split(';')
      );

      //new user scenerio when there is no related UT exist
      lstOfUserTerritory.addAll(
        createNewActiveUserTerritories(objUser, mapOfTerritory, setOfTerritory)
      );
    }
    return lstOfUserTerritory;
  }

  /**
   * @description set up Territory for Users
   * @name setUpTerritoryForActiveUsers
   * @param lstOfUsers List of Users
   * @param mapOfUserTerritory Map<Id, List<User_Territory__c>>
   * @param mapOfTerritory Map<String, Territory__c>
   * @return List<User_Territory__c>
   */
  @TestVisible
  private static List<User_Territory__c> setUpTerritoryForActiveUsers(
    List<User> lstOfUsers,
    Map<Id, List<User_Territory__c>> mapOfUserTerritory,
    Map<String, Territory__c> mapOfTerritory
  ) {
    List<User> existingActiveUsers = ListUtil.filter(lstOfUsers)
      .equals(User.isActive, true)
      .equals(User.Id, mapOfUserTerritory.keySet())
      .allNotNull(USER_FIELDS)
      .toList();
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    for (User objUser : existingActiveUsers) {
      Set<String> setOfTerritory = new Set<String>(
        objUser.ML_Territories__c.split(';')
      );
      //existing/update user scenerio and remove the existing territory from the set
      lstOfUserTerritory.addAll(
        updateExistingUserTerritoryForActiveUsers(
          objUser,
          mapOfUserTerritory.get(objUser.Id) ?? null,
          setOfTerritory
        )
      );
      // creating new territory records that does not exists for the user
      lstOfUserTerritory.addAll(
        createNewActiveUserTerritories(objUser, mapOfTerritory, setOfTerritory)
      );
    }
    return lstOfUserTerritory;
  }

  /**
   * @description set up Territory for Users
   * @name setUpTerritoryForInActiveUsers
   * @param lstOfUsers List of Users
   * @param mapOfUserTerritory Map<Id, List<User_Territory__c>>
   * @return List<User_Territory__c>
   */
  @TestVisible
  private static List<User_Territory__c> setUpTerritoryForInActiveUsers(
    List<User> lstOfUsers,
    Map<Id, List<User_Territory__c>> mapOfUserTerritory
  ) {
    List<User> existingUTUsers = ListUtil.filter(lstOfUsers)
      .equals(User.Id, mapOfUserTerritory.keySet())
      .toList();
    //existing update inactive user scenerio and user is deactivated
    List<User> inActiveUsers = ListUtil.filter(existingUTUsers)
      .equals(User.isActive, false)
      .toList();
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    for (User objUser : inActiveUsers) {
      List<User_Territory__c> existingUserTerritories = mapOfUserTerritory.get(
        objUser.Id
      ) ?? null;
      ListUtil.setField(
        existingUserTerritories,
        User_Territory__c.Status__c,
        INACTIVE_STATUS
      );
      lstOfUserTerritory.addAll(existingUserTerritories);
    }
    //existing update user scenerio and user terriroty/Role is removed
    List<User> usersWithBlankTerritoryOrRole = ListUtil.filter(existingUTUsers)
      .equals(User.isActive, true)
      .anyEqual(USER_FIELDS, null)
      .toList();
    for (User objUser : usersWithBlankTerritoryOrRole) {
      List<User_Territory__c> existingUserTerritories = mapOfUserTerritory.get(
        objUser.Id
      ) ?? null;
      ListUtil.setField(
        existingUserTerritories,
        User_Territory__c.Status__c,
        INACTIVE_STATUS
      );
      lstOfUserTerritory.addAll(existingUserTerritories);
    }
    return lstOfUserTerritory;
  }

  /**
   * @description update Existing User Territory For Active Users
   * @name updateExistingUserTerritoryForActiveUsers
   * @param objUser User
   * @param existingUserTerritories List<User_Territory__c> existing User territories
   * @param setOfTerritory Set<String>
   * @return List<User_Territory__c>
   */
  @TestVisible
  private static List<User_Territory__c> updateExistingUserTerritoryForActiveUsers(
    User objUser,
    List<User_Territory__c> existingUserTerritories,
    Set<String> setOfTerritory
  ) {
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    for (User_Territory__c eachTerritory : existingUserTerritories) {
      eachTerritory.ML_Role__c = objUser.ML_Role__c;
      if (setOfTerritory.contains(eachTerritory.Territory__r.Name)) {
        eachTerritory.Status__c = STATUS_ACTIVE;
        setOfTerritory.remove(eachTerritory.Territory__r.Name);
      } else {
        eachTerritory.Status__c = INACTIVE_STATUS;
      }
      lstOfUserTerritory.add(eachTerritory);
    }
    return lstOfUserTerritory;
  }

  /**
   * @description create New UserTerritories For Active Users
   * @name createNewActiveUserTerritories
   * @param objUser User
   * @param mapOfTerritory Map<String, String>
   * @param setOfTerritory Set<String>
   * @return List<User_Territory__c>
   */
  @TestVisible
  private static List<User_Territory__c> createNewActiveUserTerritories(
    User objUser,
    Map<String, Territory__c> mapOfTerritory,
    Set<String> setOfTerritory
  ) {
    List<User_Territory__c> lstOfUserTerritory = new List<User_Territory__c>();
    for (String eachTerritory : setOfTerritory) {
      User_Territory__c objTerritory = new User_Territory__c();
      objTerritory.User__c = objUser.Id;
      objTerritory.Status__c = STATUS_ACTIVE;
      objTerritory.ML_Role__c = objUser.ML_Role__c;
      objTerritory.Territory__c = mapOfTerritory.get(eachTerritory).Id;
      lstOfUserTerritory.add(objTerritory);
    }
    return lstOfUserTerritory;
  }
}
