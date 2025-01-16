/**
 * @author Shivam Swaraj
 * @since 11/2024
 * @description  AccountClosureActionNotifier this class will be used to post chatter feed in case of Fabric Seal Precheck Failure.
 */
public with sharing class AccountClosureActionNotifier {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );
  private static final String NO_FAILED_REASON_FOUND_ERROR = 'No Failed Reason Record Found ';

  /**
   * @description post failure message on the sobject id passed
   * @param sObjectId Id of the case record
   * @param failureReasons Set<String> failure reasons
   */
  public static void postFailureMessage(
    String sObjectId,
    Set<String> failureReasons
  ) {
    if (sObjectId == null || failureReasons.isEmpty()) {
      return;
    }

    List<AccountClosureErrorMetadata__mdt> failureActions = ACCOUNT_CLOSURE_REPOSITORY.getFailureMetadata(
      failureReasons
    );

    if (failureActions.isEmpty()) {
      throw CommonUtil.logException(
        new AccountClosureApiRepository.NoFailedReasonFoundException(
          NO_FAILED_REASON_FOUND_ERROR
        )
      );
    }

    //Compose Chatter Message
    String richTextMessage = AccountClosureMessageComposer.composeRichTextMessage(
      failureActions
    );

    if (String.isBlank(richTextMessage)) {
      return;
    }

    postFeedItemWithRichText(sObjectId, richTextMessage);
  }

  /**
   * @description method to call framework to post feed items on chatter for the given sobjectid
   * @param sObjectId Id of the case record
   * @param richTextMessage message to be posted on chatter
   */
  @testVisible
  private static void postFeedItemWithRichText(
    String sObjectId,
    String richTextMessage
  ) {
    ConnectApiHelper.postFeedItemWithRichText(null, sObjectId, richTextMessage);
  }
}
