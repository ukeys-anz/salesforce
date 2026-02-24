/**
 *
 * @author Amisha Gyani
 * @since January, 2026
 * @description CCRMAgentCapDiaryCommentsPrompt is an invocable Apex class Invocable class to fetch CAP Diary Comments for a given Account.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMAgentCapDiaryCommentsPrompt {
  private static final String CCR_CHANGED_FROM = 'CCR CHANGED FROM';
  /**
   * @description Repository for all query operations (injectable for tests).
   */
  private static final CCRMAgentforceRepository REPO = (CCRMAgentforceRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceRepository.class
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
    public String Prompt;
  }

  /**
   * @description Invocable method to fetch CAP Diary Comments for the given account.
   * @param requests List of Request objects containing Account
   * @return List of Response objects with JSON payload of comments
   */
  @InvocableMethod(
    label='CCRMAgent Get CAP Diary Comments'
    description='Returns CAP Diary Comments filtered by Date_Placed__c, Description, and Expiry_Date__c'
  )
  public static List<Response> getDiaryComments(List<Request> requests) {
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
    if (String.isBlank(acc.External_Id__c)) {
      output.Prompt = 'Account External ID is missing. Unable to fetch CAP Diary Comments.';
      return new List<Response>{ output };
    }
    List<Diary_Comment__x> allComments = REPO.fetchDiaryCommentsForExternalId(
      acc.External_Id__c
    );
    Logger.debug('Total comments fetched: ' + allComments.size());

    Date today = Date.today();
    Date past24Months = today.addMonths(-24);

    List<Map<String, Object>> displayList = new List<Map<String, Object>>();
    Integer totalRecentComments = 0;

    for (Diary_Comment__x dc : allComments) {
      Date datePlaced = parseDate(
        dc.Date_Placed__c != null ? dc.Date_Placed__c.split(' ')[0] : null
      );
      if (!dc.Permanent__c && datePlaced == null) {
        continue;
      }

      if (!dc.Permanent__c && datePlaced != null && datePlaced < past24Months) {
        continue;
      }

      totalRecentComments++;

      if (
        dc.Description__c != null &&
        dc.Description__c.contains(CCR_CHANGED_FROM)
      ) {
        continue;
      }

      Date expiry = parseDate(dc.Expiry_Date__c);
      if (expiry != null && expiry < today) {
        continue;
      }

      if (displayList.size() < 10) {
        displayList.add(
          new Map<String, Object>{
            'AccountName' => acc.Name,
            'Comment' => dc.Description__c,
            'Permanent' => dc.Permanent__c
          }
        );
      }
    }

    Map<String, Object> payload = new Map<String, Object>{
      'TotalRecentDiaryComments' => totalRecentComments,
      'DisplayedCount' => displayList.size(),
      'DiaryComments' => displayList
    };

    output.Prompt = JSON.serializePretty(payload);
    Logger.debug('CCRMAgentCapDiaryCommentsPrompt output.Prompt: ')
      .setPayload(output.Prompt)
      .save();
    return new List<Response>{ output };
  }

  /**
   * @description Helper method to parse a Text date (DD/MM/YYYY) to a Date.
   * @param dateStr Text value of the date
   * @return Date instance or null if invalid
   */
  private static Date parseDate(String dateStr) {
    if (String.isBlank(dateStr)) {
      return null;
    }
    try {
      List<String> parts = dateStr.split('/');
      if (parts.size() != 3) {
        return null;
      }
      Integer day = Integer.valueOf(parts[0]);
      Integer month = Integer.valueOf(parts[1]);
      Integer year = Integer.valueOf(parts[2]);
      return Date.newInstance(year, month, day);
    } catch (Exception e) {
      return null;
    }
  }
}
