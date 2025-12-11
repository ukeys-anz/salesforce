/**
 *
 * @author Amisha Gyani
 * @since 2025
 * @description CCRMAgentFetchTasks is an invocable Apex class that retrieves
 *              all open tasks for a given Account and returns them in a JSON-formatted
 *              string for use in prompt-based Salesforce Agents.
 */
public with sharing class CCRMAgentFetchTasks {
  private static final TaskActionRepository TASK_REPOSITORY = (TaskActionRepository) Lib_InstanceProvider.forType(
    TaskActionRepository.class
  );

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
    public String promptResponse;
  }

  /**
   * @description Invocable method that fetches all open Tasks related to the provided Account
   *              and returns their details in JSON format for agent processing.
   *
   * @param requests List of Request wrapper objects containing Account details
   * @return List of Response objects each containing a JSON-formatted prompt
   */
  @InvocableMethod(
    label='Agent Action to Fetch Customer Open Tasks'
    description='Returns all open tasks for the given Account in JSON format for use in prompts.'
  )
  public static List<Response> getOpenTasks(List<Request> requests) {
    Response output = new Response();
    if (requests.isEmpty()) {
      output.promptResponse = 'No Account data provided.';
      return new List<Response>{ output };
    }

    // Extract Account Id
    Id accountId = requests[0].accountObj.Id;

    List<Task> openTasks = TASK_REPOSITORY.getOpenTasks(accountId);
    if (openTasks.isEmpty()) {
      output.promptResponse = 'No open tasks found for this Account.';
      return new List<Response>{ output };
    }
    Map<String, Object> responseData = new Map<String, Object>{
      'OpenTasks' => openTasks
    };
    output.promptResponse = JSON.serializePretty(responseData);
    return new List<Response>{ output };
  }
}
