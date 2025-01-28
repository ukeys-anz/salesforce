/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Helper Class for AccountClosureController for Account Closure Prechecks
 */
public with sharing class AccountClosureControllerHelper {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String TECHNICAL_ERROR = 'techError';

  /**
   * @description method to prepare map of successful cases and failed cases
   * @param successCases pass by reference for map of successfull cases and their business process id
   * @param failedCases  pass by reference for map of failed cases and their failed reasons
   * @param accountClosurePrecheckResponse consolidated fabric seal response
   */
  public static void segregrateCasesByResponseStatus(
    Map<String, String> successCases,
    Map<String, Set<String>> failedCases,
    List<CaseInputWrapper> accountClosurePrecheckResponse
  ) {
    for (CaseInputWrapper response : accountClosurePrecheckResponse) {
      switch on response.acceptance {
        when 'ACCEPTANCE_ACCEPTED' {
          successCases.put(
            response.salesforceCaseNumber,
            response.businessProcessId
          );
        }
        when 'ACCEPTANCE_REJECTED' {
          failedCases.put(
            response.salesforceCaseNumber,
            new Set<String>(response.failedReasons)
          );
        }
        when else {
          failedCases.put(
            response.salesforceCaseNumber,
            new Set<String>{ TECHNICAL_ERROR }
          );
        }
      }
    }
  }

  /**
   * @description method to create set of failed reasons whose eligibility is ineligible
   * @param cases List of Eligible Cases for Precheck
   * @return Map<String, Id> map of CaseNumber and Id
   */
  public static Map<String, Id> createCaseNumberToIdMap(List<Case> cases) {
    Map<String, Id> caseNumberToIdMap = new Map<String, Id>();
    for (Case caseRec : cases) {
      caseNumberToIdMap.put(caseRec.CaseNumber, caseRec.Id);
    }
    return caseNumberToIdMap;
  }

  /**
   * @description method to prepare list of cases to update
   * @param successCases map of successfull cases and their business process id
   * @param failedCases map of failed cases and their failed reasons
   * @param caseNumberToIdMap Map<String, Id>
   * @return List of cases to be updated
   */
  public static List<Case> prepareCasesForUpdate(
    Map<String, String> successCases,
    Map<String, Set<String>> failedCases,
    Map<String, Id> caseNumberToIdMap
  ) {
    List<Case> casesToUpdate = new List<Case>();

    Set<String> allPrecheckedCases = new Set<String>();
    allPrecheckedCases.addAll(successCases.keySet());
    allPrecheckedCases.addAll(failedCases.keySet());

    for (String caseNumber : allPrecheckedCases) {
      Case caseRecord = new Case(Id = caseNumberToIdMap.get(caseNumber));

      if (successCases.containsKey(caseNumber)) {
        caseRecord.Sub_Status__c = GetHelpConstants.PROCESSING;
        caseRecord.Process_ID__c = successCases.get(caseNumber);
      } else {
        caseRecord.Sub_Status__c = GetHelpConstants.FAILED;

        postFailureMessage(
          caseNumberToIdMap.get(caseNumber),
          failedCases.get(caseNumber)
        );
      }
      casesToUpdate.add(caseRecord);
    }
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
      if (actions.Type__c == 'Constant') {
        constantMessages.add(actions.Chatter_Post__c);
      } else {
        if (!reasonToActions.containsKey(actions.Failure_Reason__c)) {
          reasonToActions.put(actions.Failure_Reason__c, new List<String>());
          reasonToActionLabelMap.put(actions.Failure_Reason__c, actions.Label);
        }

        List<String> actionsBullet = actions.Chatter_Post__c.split('\n');
        reasonToActions.get(actions.Failure_Reason__c).addAll(actionsBullet);
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
}
