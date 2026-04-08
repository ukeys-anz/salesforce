/**
 *
 * @author Amisha Gyani
 * @since February, 2026
 * @description CCRMAgentCustomerComplaintsPrompt is an Invocable Apex class used by Agentforce to fetch Customer Complaint Case details for a given Account.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMAgentCustomerComplaintsPrompt {
  /**
   * @description Repository for all query operations (injectable for tests).
   */
  private static final CCRMAgentforceRepository REPO = (CCRMAgentforceRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceRepository.class
  );

  private final static String DateFormat = 'dd MMMM yyyy, hh:mm a';

  /**
   * @description Wrapper class for input request containing the Account record
   */
  public class Request {
    @InvocableVariable(required=true)
    public Account accountObj;
  }

  /**
   * @description Wrapper class for output structure returned to the invocable consumer
   */
  public class Response {
    @InvocableVariable
    public String Prompt;
  }

  /**
   * @description
   * Invocable method to fetch Customer Complaints for the given Account.
   * - If Account Record Type is CLG, complaints are fetched for all related entities
   * - Otherwise, only complaints for the provided Account are returned
   *
   * Output contains ONLY customer complaint details.
   *
   * @param requests List of Request objects containing Account
   * @return List<Response> JSON array of customer complaint records
   */
  @InvocableMethod(
    label='CCRMAgent Get Customer Complaints'
    description='Returns Customer Complaint Case details for an Account'
  )
  public static List<Response> getCustomerComplaints(List<Request> requests) {
    Response output = new Response();

    // Validate input
    if (
      requests == null ||
      requests.isEmpty() ||
      requests[0].accountObj == null
    ) {
      output.Prompt = '[]';
      return new List<Response>{ output };
    }

    Account acc = requests[0].accountObj;

    // Determine Account Ids to be used in Case query
    Set<Id> accountIds = new Set<Id>();
    accountIds.add(acc.Id);
    // CLG accounts include related entities
    if (acc.RecordTypeId == RTAccount.clgAccount) {
      Logger.debug('Account is CLG. Fetching related entities.');
      List<FinServ__AccountAccountRelation__c> relations = REPO.fetchAccountRelationsForCLG(
        acc.Id
      );
      Logger.debug('Total related accounts found: ' + relations.size());
      for (FinServ__AccountAccountRelation__c relation : relations) {
        if (relation.FinServ__RelatedAccount__c != null) {
          accountIds.add(relation.FinServ__RelatedAccount__c);
        }
      }
    }
    // Fetch customer complaint cases
    List<Case> complaintCases = REPO.fetchCustomerComplaints(accountIds);
    Logger.debug('Total complaint cases fetched: ' + complaintCases.size());
    // Build output payload (ONLY complaint details)
    List<Map<String, Object>> complaints = new List<Map<String, Object>>();

    for (Case c : complaintCases) {
      complaints.add(
        new Map<String, Object>{
          'CaseId' => c.Id,
          'RecordType' => c.RecordType.DeveloperName,
          'CaseNumber' => c.CaseNumber,
          'Date/Time Opened' => DateTimeUtils.getLocalTime(
            c.CreatedDate,
            UserInfo.getTimeZone().getID(),
            DateFormat
          ),
          'Date/Time Closed' => DateTimeUtils.getLocalTime(
            c.ClosedDate,
            UserInfo.getTimeZone().getID(),
            DateFormat
          )
        }
      );
    }
    Logger.debug('Final complaint count in payload: ' + complaints.size());
    // Serialize ONLY the customer complaints list
    output.Prompt = JSON.serializePretty(complaints);
    Logger.saveLog();
    return new List<Response>{ output };
  }
}
