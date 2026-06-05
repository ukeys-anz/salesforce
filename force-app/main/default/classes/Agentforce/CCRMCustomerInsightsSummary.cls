/**
 * @author Agentforce
 * @description Invocable class to fetch and summarize customer insights for a given Account.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMCustomerInsightsSummary {
  private static final CCRMAgentBQRepository REPO = (CCRMAgentBQRepository) Lib_InstanceProvider.forType(
    CCRMAgentBQRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  /**
   * @description Request wrapper for the invocable method.
   *              Pass the Account SObject so we can read External_Id__c.
   */
  public class Request {
    @InvocableVariable(required=true)
    public Account accountObj;
  }

  /**
   * @description Response wrapper for the invocable method containing the JSON snapshot.
   */
  public class Response {
    @InvocableVariable
    public String Prompt;
  }

  /**
   * @description Invocable method to get customer insights for an Account. Expects Account record in the request to read the external customer number, then queries BQ repository for insights and returns a formatted JSON string in the response.
   * @param requests List<Request> containing input Account record.
   * @return List<Response> containing formatted JSON summary output.
   */
  @InvocableMethod(
    label='Get Customer Insights'
    description=' Returns Customer Insights for an Account'
  )
  public static List<Response> getCustomerInsights(List<Request> requests) {
    Response output = new Response();

    if (
      requests == null ||
      requests.isEmpty() ||
      requests[0].accountObj == null
    ) {
      output.Prompt = 'No Account provided.';
      return new List<Response>{ output };
    }

    Account acc = requests[0].accountObj;

    if (String.isBlank(acc.Source_System_ID__c)) {
      output.Prompt = 'Account Source_System_ID__c is missing. Unable to fetch Customer Insights.';
      return new List<Response>{ output };
    }

    Set<String> custNoStrSet = new Set<String>{
      String.valueOf(acc.Source_System_ID__c)
    };

    List<Customer_Insights__dlm> customerInsights = new List<Customer_Insights__dlm>();
    List<WholeOfCustomer__dlm> wocInsights = new List<WholeOfCustomer__dlm>();

    // Only fetch full customer and WOC insights for clgAccount record types.
    if (acc.RecordTypeId == RTAccount.clgAccount) {
      customerInsights = REPO.fetchCustomerInsightsByCustomerNumbers(
        Decimal.valueOf(acc.Source_System_ID__c)
      );
      wocInsights = REPO.fetchWOCInsights(custNoStrSet);
    }

    // Fetch CAZ assessment data for all accounts
    List<CAZ_Assessment2__dlm> cazAssessments = REPO.fetchCAZAssessmentByCustomerNumber(
      acc.Source_System_ID__c
    );

    Map<String, Object> payload = new Map<String, Object>{
      'customerInsights' => customerInsights,
      'wocInsights' => wocInsights,
      'cazAssessments' => cazAssessments
    };

    output.Prompt = JSON.serializePretty(payload);

    Logger.debug('CCRMCustomerInsightsSummary output.Prompt: ')
      .setPayload(output.Prompt)
      .save();

    return new List<Response>{ output };
  }
}
