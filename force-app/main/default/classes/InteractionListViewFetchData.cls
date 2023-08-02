/**
 * @author Nagendra Singh
 * @since July 2023
 * @description InteractionListViewFetchData
 */
global with sharing class InteractionListViewFetchData implements omnistudio.VlocityOpenInterface, Callable {
  private final static Integer MAXLIMIT = 5000;
  /**
   * @description invokeMethod to handle insertion of logs from omnistudio.
   * @param methodName Method named to be called.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    Boolean success = true;
    String error = '';
    try {
      if (methodName == 'fetchDataBasedOnRecordId') {
        fetchDataBasedOnRecordId(inputMap, outMap, options);
      }
    } catch (Exception e) {
      error = e.getMessage() + ' StackTrace -> ' + e.getStackTraceString();
      success = false;
    }
    return success;
  }

  /**
   * @description this method helps in fetch the interaction records based on the recordtypename and parent id.
   * @param inputMap Input from omnistudio component as a key value pair.
   * @param outMap Output to be returned as a response to caller Omnicomponent.
   * @param options Options passed from omnistudio.
   */
  public void fetchDataBasedOnRecordId(
    Map<String, Object> inputMap,
    Map<String, Object> outMap,
    Map<String, Object> options
  ) {
    String anyRecordId = (String) inputMap.get('anyRecordId');
    String recordTypeDeveloperName = (String) inputMap.get(
      'recordTypeDeveloperName'
    );
    List<String> statusSearch = (List<String>) inputMap.get('statusSearch');
    Integer maxNumber = (inputMap.get('maxNumber') == null)
      ? MAXLIMIT
      : (Integer) inputMap.get('maxNumber');
    String interactionQuery = 'SELECT Id,RecordType.DeveloperName,Chat_or_Call_SID__c, Name, Interaction_Auto_Number__c, AccountId, Account.Name,Lead__c, Lead__r.Name,StartTime,Interaction_Purpose__c, Contact_Mobile__c,InteractionType,Resolution__c ,Owner.Name ,CreatedDate, Actual_Topics__c, Reason_for_Visit__c, Status__c, Place__c, Attendees__c ,Video_Call__c, Direction__c From Interaction WHERE ';
    String sobjectType = String.valueOf(
      Id.valueOf(anyRecordId).getSObjectType()
    );

    switch on sobjectType {
      when 'Account' {
        interactionQuery += 'AccountId = :anyRecordId';
      }
      when 'Case' {
        interactionQuery += 'CaseId__c = :anyRecordId';
      }
      when 'Coaching_Summary__c' {
        interactionQuery += 'Coaching_Summary__c = :anyRecordId';
      }
      when 'Lead' {
        interactionQuery += 'Lead__c = :anyRecordId';
      }
      when 'ResidentialLoanApplication' {
        interactionQuery += 'Loan_Application__c = :anyRecordId';
      }
    }

    //statusSearch works conditionally when passed from LWC or Aura.When the status search is passed then it will be appended to the query and records will be filtered based on that.
    interactionQuery += ' AND RecordType.DeveloperName = :recordTypeDeveloperName';
    if (statusSearch != null && !statusSearch.isEmpty()) {
      interactionQuery +=
        ' AND Status__c IN (\'' +
        String.join(statusSearch, '\',\'') +
        '\') ';
    }
    interactionQuery += ' ORDER BY CreatedDate DESC';
    interactionQuery += ' LIMIT ' + maxNumber;
    List<Interaction> lstInteractionsFromDB = (List<Interaction>) Database.query(
      interactionQuery
    );
    outMap.put('interactions', lstInteractionsFromDB);
  }

  /**
   * @description Overriden method from Callable interface to invoke methods dynamically based on action passed.
   * @param action Dynamic method name to be called.
   * @param args Dynamic arguments to passed from omnistudio.
   * @return Object containing outMap, which can contain custom message and should return success as false and true based on logic.
   */
  global Object call(String action, Map<String, Object> args) {
    Map<String, Object> input = (Map<String, Object>) args.get('input');
    Map<String, Object> output = (Map<String, Object>) args.get('output');
    Map<String, Object> options = (Map<String, Object>) args.get('options');

    return invokeMethod(action, input, output, options);
  }
}
