/**
 * @author Naman Garg
 * @since  07/2024
 * @group CCRM (Commercial CRM)
 * @description CCRMControllingPostHelper is the helper class for CCRMPopulateCPIDUserBatch
 */
public with sharing class CCRMControllingPostHelper {
  /**
   * @description This is used to get the LanIds of the Controlling Post record
   * @name getLanIds
   * @param cpList List of Controlling Post records
   * @return Set<String> Set of Lan Ids
   */
  public static Set<String> getLanIds(List<Controlling_Post__c> cpList) {
    Set<String> lanIdsSet = new Set<String>();
    for (Controlling_Post__c cpItr : cpList) {
      if (cpItr.CPID_LanID__c != null && cpItr.CPID_User__c == null) {
        lanIdsSet.add(cpItr.CPID_LanID__c);
      }
    }
    return lanIdsSet;
  }

  /**
   * @description This is used to form the User Map
   * @name formLanIdToUserMap
   * @param userList List of active user
   * @return Map<String, User> Map of Lan Id and User record
   */
  public static Map<String, User> formLanIdToUserMap(List<User> userList) {
    Map<String, User> lanIdUserMap = new Map<String, User>();
    for (User userItr : userList) {
      lanIdUserMap.put(userItr.Lan_Id__c.toLowerCase(), userItr);
    }
    return lanIdUserMap;
  }

  /**
   * @description This is populate the User lookup based on Lan Id
   * @name setUserLookup
   * @param cpList List of Controlling Post records
   * @param mapOfLanIdToUser Map of Lan Id to User
   * @return List<Controlling_Post__c> Controlling post record to be updated
   */
  public static List<Controlling_Post__c> setUserLookup(
    List<Controlling_Post__c> cpList,
    Map<String, User> mapOfLanIdToUser
  ) {
    List<Controlling_Post__c> cpRecordToUpdateList = new List<Controlling_Post__c>();
    if (mapOfLanIdToUser.isEmpty()) {
      return cpRecordToUpdateList;
    }
    for (Controlling_Post__c cpItr : cpList) {
      if (mapOfLanIdToUser.containsKey(cpItr.CPID_LanID__c.toLowerCase())) {
        cpItr.CPID_User__c = mapOfLanIdToUser.get(
            cpItr.CPID_LanID__c.toLowerCase()
          )
          .Id;
        cpRecordToUpdateList.add(cpItr);
      }
    }
    return cpRecordToUpdateList;
  }
}
