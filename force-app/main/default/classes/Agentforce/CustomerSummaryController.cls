/**
 * @author Agentforce Team
 * @since May 2026
 * @description Lightweight controller exposing Aura-enabled methods to generate
 *              various customer summary HTML fragments by invoking Prompt Builder
 *              prompts via PromptUtils. Each method accepts an Account Id and
 *              returns an HTML string (may contain markup).
 */
public with sharing class CustomerSummaryController {
  private final static String BOT_NAME = 'Banking_Relationship_Assistance';
  /**
   * @description Generates key discussion points for the provided Account Id by invoking
   *              the Prompt Builder prompt named 'Customer_Summary_1' via PromptUtils.
   * @param accountId Id of the Account to derive discussion points for.
   * @return String HTML fragment containing key discussion points. Returns a placeholder
   *         '<p><b>No summary generated.</b></p>' if the prompt returns blank or null.
   */
  @AuraEnabled(cacheable=false)
  public static String generateKeyDisscussionPoints(Id accountId) {
    // Build record reference map (ONLY id is required)
    Map<String, String> accountRef = new Map<String, String>();
    accountRef.put('id', String.valueOf(accountId));

    // Wrap it
    ConnectApi.WrappedValue accountValue = new ConnectApi.WrappedValue();
    accountValue.value = accountRef;

    // Input params map
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

    // Must match Prompt Builder input API name
    inputParams.put('Input:Account', accountValue);

    // Invoke prompt via shared utility
    String response = PromptUtils.invokePrompt(
      'Customer_Summary_1',
      inputParams
    );

    if (String.isBlank(response)) {
      return '<p><b>No summary generated.</b></p>';
    }

    return response; // HTML
  }

  /**
   * @description Generates an account snapshot and diary-style comments for the provided Account Id by invoking
   *              the Prompt Builder prompt named 'Customer_Summary_2' via PromptUtils.
   * @param accountId Id of the Account to generate snapshot and diary comments for.
   * @return String HTML fragment containing the snapshot and diary comments or a placeholder if none generated.
   */
  @AuraEnabled(cacheable=false)
  public static String generateAccountSnapshotAndDiaryComments(Id accountId) {
    // Build record reference map (ONLY id is required)
    Map<String, String> accountRef = new Map<String, String>();
    accountRef.put('id', String.valueOf(accountId));

    // Wrap it
    ConnectApi.WrappedValue accountValue = new ConnectApi.WrappedValue();
    accountValue.value = accountRef;

    // Input params map
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

    // Must match Prompt Builder input API name
    inputParams.put('Input:Account', accountValue);

    // Invoke prompt via shared utility
    String response = PromptUtils.invokePrompt(
      'Customer_Summary_2',
      inputParams
    );

    if (String.isBlank(response)) {
      return '<p><b>No summary generated.</b></p>';
    }

    return response; // HTML
  }

  /**
   * @description Generates a summary of opportunities and leads related to the provided Account Id by invoking
   *              the Prompt Builder prompt named 'Customer_Summary_3' via PromptUtils.
   * @param accountId Id of the Account to gather opportunities and leads for.
   * @return String HTML fragment containing opportunities and leads or a placeholder if the prompt returns blank.
   */
  @AuraEnabled(cacheable=false)
  public static String generateOpportunitiesAndLeads(Id accountId) {
    // Build record reference map (ONLY id is required)
    Map<String, String> accountRef = new Map<String, String>();
    accountRef.put('id', String.valueOf(accountId));

    // Wrap it
    ConnectApi.WrappedValue accountValue = new ConnectApi.WrappedValue();
    accountValue.value = accountRef;

    // Input params map
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

    // Must match Prompt Builder input API name
    inputParams.put('Input:Account', accountValue);

    // Invoke prompt via shared utility
    String response = PromptUtils.invokePrompt(
      'Customer_Summary_3',
      inputParams
    );

    if (String.isBlank(response)) {
      return '<p><b>No summary generated.</b></p>';
    }

    return response; // HTML
  }

  /**
   * @description Generates miscellaneous customer information and open tasks for the provided Account Id by invoking
   *              the Prompt Builder prompt named 'Customer_Summary_4' via PromptUtils.
   * @param accountId Id of the Account to generate miscellaneous details and tasks for.
   * @return String HTML fragment containing miscellaneous details and open tasks or a placeholder if none generated.
   */
  @AuraEnabled(cacheable=false)
  public static String generateOtherAndTasks(Id accountId) {
    // Build record reference map (ONLY id is required)
    Map<String, String> accountRef = new Map<String, String>();
    accountRef.put('id', String.valueOf(accountId));

    // Wrap it
    ConnectApi.WrappedValue accountValue = new ConnectApi.WrappedValue();
    accountValue.value = accountRef;

    // Input params map
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();

    // Must match Prompt Builder input API name
    inputParams.put('Input:Account', accountValue);

    // Invoke prompt via shared utility
    String response = PromptUtils.invokePrompt(
      'Customer_Summary_4',
      inputParams
    );

    if (String.isBlank(response)) {
      return '<p><b>No summary generated.</b></p>';
    }

    return response;
  }

  /**
   * @description Retrieves the Bot Id for the bot used in this solution, which is needed to route user feedback to the correct bot in CCRM. The bot is named 'Banking_Relationship_Assistance'.
   * @return Id of the bot with DeveloperName 'Banking_Relationship_Assistance'. Returns null if no such bot is found.
   */

  @AuraEnabled(cacheable=true)
  public static Id getBotId() {
    BotDefinition bot = [
      SELECT Id, DeveloperName
      FROM BotDefinition
      WHERE DeveloperName = :BOT_NAME
      LIMIT 1
    ];
    return bot.Id;
  }
}
