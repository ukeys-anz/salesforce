/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Helper Class for AccountClosureController for Account Closure Prechecks
 */
public with sharing class AccountClosureControllerHelper {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final String ACCOUNT_NOT_FOUND_ERROR = 'No account with given number found or it is not at closable status';

  private static final Set<String> ACCESS_ERROR_CODES = new Set<String>{
    '400',
    '403',
    '404'
  };

  /**
   * @description method to prepare list of cases to update
   * @param accountClosurePrecheckResponse consolidated fabric seal response
   * @param caseNumberToIdMap Map<String, Case>
   * @return List of cases to be updated
   */
  public static List<Case> prepareCasesForUpdate(
    List<CaseInputWrapper> accountClosurePrecheckResponse,
    Map<String, Case> caseNumberToIdMap
  ) {
    List<Case> casesToUpdate = new List<Case>();
    for (CaseInputWrapper response : accountClosurePrecheckResponse) {
      Id caseId = caseNumberToIdMap?.get(response.salesforceCaseNumber)?.Id;
      Case caseRecord = new Case(Id = caseId);
      switch on response.acceptance {
        when 'ACCEPTANCE_ACCEPTED' {
          caseRecord.Sub_Status__c = GetHelpConstants.PROCESSING;
          caseRecord.Process_ID__c = response.businessProcessId;
        }
        when 'ACCEPTANCE_REJECTED' {
          caseRecord.Sub_Status__c = GetHelpConstants.FAILED;
          postFailureMessage(caseId, new Set<String>(response.failedReasons));
        }
        when else {
          handleLogResponse(response);
          caseRecord.Sub_Status__c = GetHelpConstants.FAILED;
          if (response.message.contains(ACCOUNT_NOT_FOUND_ERROR)) {
            postFailureMessage(caseId, new Set<String>{ 'accountNotFound' });
          } else {
            postFailureMessage(caseId, new Set<String>{ 'techError' });
          }
        }
      }
      casesToUpdate.add(caseRecord);
    }
    Logger.saveLog();
    return casesToUpdate;
  }

  /**
   * @description post failure message on the sobject id passed
   * @param sObjectId Id of the case record
   * @param failureReasons Set<String> failure reasons
   */
  private static void postFailureMessage(
    String sObjectId,
    Set<String> failureReasons
  ) {
    String richTextMessage = composeRichTextMessage(
      ACCOUNT_CLOSURE_REPOSITORY.getFailureMetadata(failureReasons)
    );

    if (!String.isBlank(richTextMessage)) {
      ConnectApiHelper.postFeedItemWithRichText(
        null,
        sObjectId,
        richTextMessage
      );
    }
  }

  /**
   * @description post failure message on the sobject id passed
   * @param actionsList list of failure actions
   * @return richText to be posted on chatter
   */
  private static String composeRichTextMessage(
    List<AccountClosureErrorMetadata__mdt> actionsList
  ) {
    //Seperate constants and failure-specific actions
    List<String> messageParts = new List<String>();
    List<String> constantMessages = new List<String>();
    Map<String, List<String>> reasonToActions = new Map<String, List<String>>();
    Map<String, String> reasonToActionLabelMap = new Map<String, String>();

    for (AccountClosureErrorMetadata__mdt actions : actionsList) {
      if (actions.Chatter_Post__c != null) {
        if (actions.Type__c == 'Constant') {
          constantMessages.add(actions.Chatter_Post__c);
        } else {
          if (!reasonToActions.containsKey(actions.Failure_Reason__c)) {
            reasonToActions.put(actions.Failure_Reason__c, new List<String>());
            reasonToActionLabelMap.put(
              actions.Failure_Reason__c,
              actions.Label
            );
          }

          List<String> actionsBullet = actions.Chatter_Post__c.split('\n');
          reasonToActions.get(actions.Failure_Reason__c).addAll(actionsBullet);
        }
      }
    }

    //Add constant message
    messageParts.addAll(constantMessages);

    //Add failure specific actions grouped by reason
    for (String reason : reasonToActions.keySet()) {
      List<String> reasonMessageParts = new List<String>();
      reasonMessageParts.add(reasonToActionLabelMap.get(reason));

      for (String action : reasonToActions.get(reason)) {
        reasonMessageParts.add('• ' + action.trim());
      }

      messageParts.add(String.join(reasonMessageParts, '\n'));
    }

    return String.join(messageParts, '\n\n').trim();
  }

  /**
   * @description log failure message as per the code received
   * @param response instance of CaseInputWrapper having each case details
   */
  private static void handleLogResponse(CaseInputWrapper response) {
    if (ACCESS_ERROR_CODES.contains(response.code)) {
      Logger.info(
        response.salesforceCaseNumber +
          ' - Precheck Failure Reason for Account Closure Process: ' +
          response.message
      );
    } else {
      Logger.error(
        response.salesforceCaseNumber +
          ' - Precheck Failure Reason from Account Closure Service: ' +
          response.message
      );
    }
  }
}
