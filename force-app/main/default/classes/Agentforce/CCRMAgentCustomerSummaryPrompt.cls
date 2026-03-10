/**
 * @author Prasanjeet Dutta
 * @since Dec 12 2025
 * @description Generates a comprehensive customer summary prompt for Salesforce Prompt Builder.
 *              This class retrieves and processes interactions, opportunities, leads, reviews,
 *              tasks, PB notes, extra care details, and user contextual information into a
 *              structured JSON output.
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMAgentCustomerSummaryPrompt {
  /**
   * @description Repository for all query operations.
   */
  private static final CCRMAgentforceRepository REPO = (CCRMAgentforceRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceRepository.class
  );
  private static final UserInfoRepository USER_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private final static String DateFormat = 'dd MMMM yyyy, hh:mm a';

  /**
   * @description Wrapper for the invocable input request.
   */
  public class Request {
    @InvocableVariable(required=true)
    public Account accountObj;
  }

  /**
   * @description Wrapper for the invocable method output.
   */
  public class Response {
    @InvocableVariable
    public String Prompt;
  }

  /**
   * @description Invocable entry point that generates the customer summary prompt.
   * @param requests List<Request> containing input Account record.
   * @return List<Response> containing formatted JSON summary output.
   */
  @InvocableMethod(label='Get Customer Summary Prompt')
  public static List<Response> getPrompt(List<Request> requests) {
    Response res = new Response();

    if (
      requests == null ||
      requests.isEmpty() ||
      requests[0].accountObj == null
    ) {
      res.Prompt = 'No account data provided.';
      return new List<Response>{ res };
    }

    Account acc = requests[0].accountObj;
    Id accId = acc.Id;
    Id rtId = acc.RecordTypeId;
    Boolean isCLG = (rtId == RTAccount.clgAccount);

    Date twoYearsAgo = Date.today().addYears(-2);
    Date sixMonthsAgo = Date.today().addMonths(-6);
    Date threeMonthsAgo = Date.today().addMonths(-3);

    // ACCOUNT
    Map<String, Object> accountMap = buildAccountMap(acc);

    // INTERACTIONS
    Integer interactionCount = isCLG
      ? REPO.fetchInteractionCountForCLG(accId, twoYearsAgo)
      : REPO.fetchInteractionCount(accId, twoYearsAgo);

    List<Interaction> interactionRecords = isCLG
      ? REPO.fetchLatestInteractionsForCLG(accId, twoYearsAgo, 15)
      : REPO.fetchLatestInteractions(accId, twoYearsAgo, 15);

    List<Map<String, Object>> interactionList = buildInteractionMap(
      interactionRecords
    );

    // OPPORTUNITIES
    List<Opportunity> opps = isCLG
      ? REPO.fetchOpportunitiesForCLG(accId, twoYearsAgo, 10)
      : REPO.fetchOpportunities(accId, twoYearsAgo, 10);

    Set<Id> oppIds = ListUtil.getIds(opps, Opportunity.Id);

    // List<OpportunityLineItem> oliList = REPO.fetchOpportunityLineItems(oppIds);

    // Fetch Application Form Products related to these Opportunities via OLI
    List<ApplicationFormProduct> afps = REPO.fetchApplicationFormProductsByOppIds(
      oppIds
    );

    List<Map<String, Object>> opportunitiesList = buildOpportunityMap(
      opps,
      afps
    );

    // LEADS
    List<Lead> leads = isCLG
      ? REPO.fetchLeadsForCLG(accId, twoYearsAgo, 10)
      : REPO.fetchLeads(accId, twoYearsAgo, 10);

    List<Map<String, Object>> leadsList = buildLeadMap(leads);

    // A-Z REVIEWS + SURVEYS
    List<A_Z_Review__c> reviews = isCLG
      ? REPO.fetchAZReviewsForCLG(accId, twoYearsAgo, 5)
      : REPO.fetchAZReviews(accId, twoYearsAgo, 5);

    Set<Id> reviewIds = ListUtil.getIds(reviews, A_Z_Review__c.Id);

    List<qualtrics__Survey_Response__c> surveys = REPO.fetchSurveyResponses(
      reviewIds
    );

    List<Map<String, Object>> azReviewsList = buildAZReviewsMap(
      reviews,
      surveys
    );

    //PB NOTES
    List<Customer_Relationship__c> rels = REPO.fetchCustomerRelationships(
      accId
    );
    List<Map<String, Object>> pbNotesList = buildPBNotes(accId, rels);

    //OPEN TASKS
    List<Task> openTaskRecords = REPO.fetchOpenTasks(accId, threeMonthsAgo);

    List<Map<String, Object>> openTasksList = buildTaskMap(openTaskRecords);

    //EXTRA CARE
    Map<String, Object> extraCareMap = buildExtraCare(acc);

    //SUGGESTED TASKS
    List<Map<String, Object>> suggestedTasks = filterSuggestedTasks(
      interactionRecords,
      reviews,
      sixMonthsAgo
    );

    // FINAL RESULT MAP
    Map<String, Object> result = new Map<String, Object>{
      'Account' => accountMap,
      'Interactions' => interactionList,
      'TotalInteractionCount' => interactionCount,
      'Opportunities' => opportunitiesList,
      'Leads' => leadsList,
      'A_Z_Reviews' => azReviewsList,
      'OpenTasks' => openTasksList,
      'PBNotes' => pbNotesList,
      'ExtraCare' => extraCareMap,
      'SuggestedTasks' => suggestedTasks,
      'UserDate' => DateTimeUtils.getLocalTime(
        System.now(),
        UserInfo.getTimeZone().getID(),
        DateFormat
      )
    };

    res.prompt = JSON.serializePretty(result);
    return new List<Response>{ res };
  }

  /**
   * @description Builds a key/value representation of the Account details.
   * @param acc Account record.
   * @return Map<String,Object> with AccountId and AccountName.
   */
  @TestVisible
  private static Map<String, Object> buildAccountMap(Account acc) {
    return new Map<String, Object>{
      'AccountId' => acc.Id,
      'AccountName' => acc.Name
    };
  }

  /**
   * @description Converts Interaction SObjects into maps for JSON output.
   * @param listRecs List of Interaction records.
   * @return List<Map<String,Object>> mapped interaction fields.
   */
  @TestVisible
  private static List<Map<String, Object>> buildInteractionMap(
    List<Interaction> listRecs
  ) {
    List<Map<String, Object>> output = new List<Map<String, Object>>();
    for (Interaction i : listRecs) {
      output.add(
        new Map<String, Object>{
          'InteractionId' => i.Id,
          'InteractionName' => i.Name,
          'InteractionSummary' => i.Optional_Notes__c,
          'InteractionType' => i.Interaction_Type__c,
          'StartTime' => DateTimeUtils.getLocalTime(
            i.StartTime,
            UserInfo.getTimeZone().getID(),
            DateFormat
          )
        }
      );
    }
    return output;
  }

  /**
   * @description Converts Opportunity & related AFP data into structured maps.
   * @param opps List of Opportunities from repository.
   * @param afps List of ApplicationFormProduct related to those opportunities.
   * @return List<Map<String,Object>> structured opportunity details.
   */
  @TestVisible
  private static List<Map<String, Object>> buildOpportunityMap(
    List<Opportunity> opps,
    List<ApplicationFormProduct> afps
  ) {
    Map<Id, List<Map<String, Object>>> afpGrouped = groupAFPsByOpportunity(
      afps
    );

    List<Map<String, Object>> output = new List<Map<String, Object>>();
    for (Opportunity o : opps) {
      output.add(
        new Map<String, Object>{
          'OpportunityId' => o.Id,
          'OpportunityName' => o.Name,
          'OpportunityOwner' => (o.Owner != null ? o.Owner.Name : null),
          'Amount' => o.Amount,
          'ApprovedAmount' => o.Approved_Amount__c,
          'ClosedDate' => o.CloseDate,
          'StageName' => o.StageName,
          'LostReason' => o.Lost_Reason__c,
          'Products' => afpGrouped.containsKey(o.Id)
            ? afpGrouped.get(o.Id)
            : new List<Map<String, Object>>()
        }
      );
    }
    return output;
  }

  /**
   * @description Groups OpportunityLineItems by their Opportunity into a simplified structure.
   * @param afps List of ApplicationFormProduct records to group.
   * @return Map<Id, List<Map<String,Object>>> keyed by OpportunityId with product details.
   */
  @TestVisible
  private static Map<Id, List<Map<String, Object>>> groupAFPsByOpportunity(
    List<ApplicationFormProduct> afps
  ) {
    Map<Id, List<Map<String, Object>>> afpGrouped = new Map<Id, List<Map<String, Object>>>();
    for (ApplicationFormProduct afp : afps) {
      if (!afpGrouped.containsKey(afp.Opportunity_Product__r.OpportunityId)) {
        afpGrouped.put(
          afp.Opportunity_Product__r.OpportunityId,
          new List<Map<String, Object>>()
        );
      }
      afpGrouped.get(afp.Opportunity_Product__r.OpportunityId)
        .add(
          new Map<String, Object>{
            'ProductName' => (afp.Product != null ? afp.Product.Name : null),
            'ProductStage' => afp.Stage
          }
        );
    }
    return afpGrouped;
  }

  /**
   * @description Converts Lead records into key/value maps for output.
   * @param leads List<Lead> from repository.
   * @return List<Map<String,Object>> mapped lead details.
   */
  @TestVisible
  private static List<Map<String, Object>> buildLeadMap(List<Lead> leads) {
    List<Map<String, Object>> output = new List<Map<String, Object>>();
    for (Lead l : leads) {
      output.add(
        new Map<String, Object>{
          'LeadId' => l.Id,
          'Name' => l.Name,
          'ResponseStatus' => l.SubStatus__c,
          'Status' => l.Status,
          'ReferralStatus' => l.Referral_Status__c
        }
      );
    }
    return output;
  }

  /**
   * @description Converts A-Z Reviews and related Survey Responses into structured output.
   * @param reviews List of A_Z_Review__c records.
   * @param surveys List of qualtrics__Survey_Response__c related to these reviews.
   * @return List<Map<String,Object>> merged structured AZ Review data.
   */
  @TestVisible
  private static List<Map<String, Object>> buildAZReviewsMap(
    List<A_Z_Review__c> reviews,
    List<qualtrics__Survey_Response__c> surveys
  ) {
    // Group survey responses by review, then assemble final output
    Map<Id, List<Map<String, Object>>> surveyGrouped = groupSurveyResponsesByReview(
      surveys
    );

    List<Map<String, Object>> output = new List<Map<String, Object>>();
    for (A_Z_Review__c r : reviews) {
      output.add(
        new Map<String, Object>{
          'Id' => r.Id,
          'Name' => r.Name,
          'BusinessDetails' => r.Business_Details__c,
          'BorrowingOFIRelationship' => r.Borrowing_OFI_Relationship__c,
          'PersonalBanking' => r.Personal_Banking__c,
          'CreatedDate' => r.CreatedDate,
          'SurveyResponses' => surveyGrouped.get(r.Id)
        }
      );
    }
    return output;
  }

  /**
   * @description Groups Survey Responses by A_Z_Review__c and converts them to simple maps.
   * @param surveys List of qualtrics__Survey_Response__c records.
   * @return Map<Id, List<Map<String,Object>>> keyed by A_Z_Review__c Id.
   */
  @TestVisible
  private static Map<Id, List<Map<String, Object>>> groupSurveyResponsesByReview(
    List<qualtrics__Survey_Response__c> surveys
  ) {
    Map<Id, List<Map<String, Object>>> surveyGrouped = new Map<Id, List<Map<String, Object>>>();
    for (qualtrics__Survey_Response__c s : surveys) {
      if (!surveyGrouped.containsKey(s.A_Z_Review__c)) {
        surveyGrouped.put(s.A_Z_Review__c, new List<Map<String, Object>>());
      }
      surveyGrouped.get(s.A_Z_Review__c)
        .add(
          new Map<String, Object>{
            'SurveyId' => s.Id,
            'SurveyResponseName' => s.Name,
            'DateCreated' => s.qualtrics__Date_Responded__c,
            'AdvocacyRating' => s.qualtrics__Net_Promoter_Score__c,
            'CustomerFeedback' => s.Customer_Feedback__c
          }
        );
    }
    return surveyGrouped;
  }

  /**
   * @description Builds PB Notes only for PB users.
   * @param accId Id of the Account.
   * @param rels List<Customer_Relationship__c> Customer Relationship Notes
   * @return List<Map<String,Object>> representing PB note fields.
   */
  @TestVisible
  private static List<Map<String, Object>> buildPBNotes(
    Id accId,
    List<Customer_Relationship__c> rels
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    User currentUser = USER_REPO.getUser();

    if (currentUser.Commercial_Segment__c != 'PB') {
      return result;
    }

    for (Customer_Relationship__c cr : rels) {
      result.add(
        new Map<String, Object>{
          'Id' => cr.Id,
          'Name' => cr.Name,
          'PrivateBankerAdvisor' => cr.Private_Banker_Advisor__r != null
            ? cr.Private_Banker_Advisor__r.Name
            : null,
          'CustomerAreasOfInterest' => cr.Customer_Areas_of_Interest__c,
          'PrioritiesAndObjectives' => cr.Priorities_and_Objectives__c,
          'OtherAccountPlanInformation' => cr.Other_Account_Plan_Information__c,
          'ANZOpportunities' => cr.ANZ_Opportunities__c,
          'CompetitiveLandscapeAndANZRelative' => cr.Competitive_Landscape_and_ANZ_Relative__c,
          'Notes' => cr.Notes__c,
          'PersonalBackground' => cr.Personal_Background__c,
          'FinancialWealthBackground' => cr.Financial_Wealth_Background__c,
          'BusinessInvestmentBackground' => cr.Business_Investment_Background__c,
          'AdditionalDetails' => cr.Additional_Details__c,
          'Status' => cr.Status__c
        }
      );
    }

    return result;
  }

  /**
   * @description Converts Task SObjects into maps for JSON output.
   * @param tasks List<Task> representing open tasks.
   * @return List<Map<String,Object>> mapped task fields.
   */
  @TestVisible
  private static List<Map<String, Object>> buildTaskMap(List<Task> tasks) {
    List<Map<String, Object>> output = new List<Map<String, Object>>();
    for (Task t : tasks) {
      output.add(
        new Map<String, Object>{
          'TaskId' => t.Id,
          'Subject' => t.Subject,
          'DueDate' => t.ActivityDate
        }
      );
    }
    return output;
  }

  /**
   * @description Evaluates and constructs Extra Care alert output.
   * @param acc Account record.
   * @return Map<String,Object> containing ShowExtraCareAlert + ExtraCareMessage.
   */
  @TestVisible
  private static Map<String, Object> buildExtraCare(Account acc) {
    Map<String, Object> ec = new Map<String, Object>{
      'ShowExtraCareAlert' => false,
      'ExtraCareMessage' => null
    };

    if (!USER_REPO.checkCustomPermission('ExtraCareReadOnly')) {
      return ec;
    }

    if (acc != null) {
      String timePeriod = (String) acc.get('ExtraCareTimePeriod__c');
      if (!String.isBlank(timePeriod) && timePeriod != 'Not Required') {
        String reason = (String) acc.get('ExtraCareReason__c');
        ec.put('ShowExtraCareAlert', true);
        ec.put(
          'ExtraCareMessage',
          'This customer currently has an <b>active Extra Care Alert</b> due to the following reasons: ' +
          (reason == null ? '' : reason)
        );
        return ec;
      }
    }

    if (acc != null) {
      Integer count = REPO.fetchAccountAccountRelationsForExtraCare(acc.Id);
      if (count > 0) {
        ec.put('ShowExtraCareAlert', true);
        ec.put(
          'ExtraCareMessage',
          'There is at least one related Extra Care customer. Please review their profile.'
        );
      }
    }

    return ec;
  }

  /**
   * @description Generates suggested tasks based on recent interactions and A-Z reviews.
   * @param interactions List<Interaction> recent interactions.
   * @param reviews List<A_Z_Review__c> recent A-Z Reviews.
   * @param sixMonthsAgo Date cutoff for "recent".
   * @return List<Map<String,Object>> recommended follow-up tasks.
   */
  @TestVisible
  private static List<Map<String, Object>> filterSuggestedTasks(
    List<Interaction> interactions,
    List<A_Z_Review__c> reviews,
    Date sixMonthsAgo
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    for (Interaction i : interactions) {
      if (i.StartTime == null) {
        continue;
      }
      if (i.StartTime < sixMonthsAgo) {
        continue;
      }
      result.add(
        new Map<String, Object>{
          'Type' => 'Interaction',
          'Id' => i.Id,
          'Name' => i.Name,
          'InteractionSummary' => i.Optional_Notes__c
        }
      );
    }

    for (A_Z_Review__c r : reviews) {
      if (r.CreatedDate == null) {
        continue;
      }
      if (r.CreatedDate < sixMonthsAgo) {
        continue;
      }
      result.add(
        new Map<String, Object>{
          'Type' => 'AZ_Review',
          'Id' => r.Id,
          'Name' => r.Name,
          'BusinessDetails' => r.Business_Details__c
        }
      );
    }
    return result;
  }
}
