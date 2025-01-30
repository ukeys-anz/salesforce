/**
 * @description       : Transaction Security Policies Handler class to block query on PrivateKeyStorage object
 * @author            : Nilesh
 * @last modified     : 3 Sept 2024
 **/

global with sharing class BlockPrivateKeyStorageEventHandler implements TxnSecurity.EventCondition, TxnSecurity.AsyncCondition {
  private static final Boolean ALLOWED = false;
  private static final Boolean NOT_ALLOWED = true;
  private static final TSPRepository TSP_REPOSITORY = (TSPRepository) Lib_InstanceProvider.forType(
    TSPRepository.class
  );

  /**
   * @description Used to check ApiEvent
   * @param event SObject which is the name of the event.
   * @return `Boolean` returns true when tried to query PrivateKeyStorage detected
   */
  public static Boolean evaluate(SObject event) {
    switch on event {
      when ApiEvent objApiEvent {
        return isPrivateKeyApiQueriedEvent(objApiEvent);
      }
    }
    return ALLOWED;
  }

  /**
   * @description To Save log in logger
   * @param objApiEvent ApiEvent
   * @return Boolean
   */
  private static Boolean isPrivateKeyApiQueriedEvent(ApiEvent objApiEvent) {
    if (objApiEvent.QueriedEntities.toLowerCase() != 'privatekeystorage__c') {
      return ALLOWED;
    }
    User eventUser = TSP_REPOSITORY.queryProfilebyEventUserId(
      objApiEvent.UserId
    );
    Logger.info(
      'Block PrivateKeyStorage Queried APIEvent has been done by ' +
        objApiEvent.Username +
        ' (Id: ' +
        eventUser.Id +
        ' ) with ' +
        eventUser.Profile.Name +
        ' profile.'
    );
    Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
    return NOT_ALLOWED;
  }
}
