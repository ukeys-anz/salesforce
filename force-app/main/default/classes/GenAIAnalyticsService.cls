/**
 * @description Service providing per-user GenAI usage analytics for the IndustriesSummarization prompt.
 *              Aggregates weekly and monthly generation counts and the latest generation timestamp,
 *              returning results to LWC via an AuraEnabled method.
 * @author duttap5
 * @since 11/2025
 * @group Agentforce
 */
public with sharing class GenAIAnalyticsService {
  /**
   * @description Wrapper returned to LWC containing user GenAI usage metrics.
   *              Holds weekly / monthly generation counts and the most recent usage timestamp.
   *              Used by getUserGenerationSummary().
   * @author duttap5
   * @since 11/2025
   */

  public class UserGenerationStats {
    /** @description The User Id tied to the GenAI usage record. */
    @AuraEnabled
    public String userId { get; set; }

    /** @description The User’s display name resolved from the User record. */
    @AuraEnabled
    public String userName { get; set; }

    /** @description The commercial segment resolved from the User record. */
    @AuraEnabled
    public String userSegment { get; set; }

    /** @description Total generations in the trailing 7 days. */
    @AuraEnabled
    public Integer weeklyGenerationCount { get; set; }

    /** @description Total generations in the trailing 30 days. */
    @AuraEnabled
    public Integer monthlyGenerationCount { get; set; }

    /** @description The most recent timestamp of generation. */
    @AuraEnabled
    public Datetime lastGeneratedTime { get; set; }

    /** @description Initializes usage counters to zero. */
    public UserGenerationStats() {
      weeklyGenerationCount = 0;
      monthlyGenerationCount = 0;
    }
  }
  /**
   * @description Checks if the current user has access to the GenAI analytics.
   * @return boolean - true if the user has access to the analytics, false otherwise.
   *
   */
  private static Boolean userHasAnalyticsAccess() {
    String requiredPS = 'GenieUserEnhancedSecurity';
    UserInfoRepository userInfoRepo = new UserInfoRepository();
    return userInfoRepo.checkPermission(requiredPS);
  }

  /**
   * @description Returns aggregated GenAI usage summary (weekly, monthly, and latest timestamp)
   *              for each user who triggered the IndustriesSummarization feature in the last 30 days.
   *              Used by LWC for real-time analytics display.
   *
   * @return List<UserGenerationStats> A list of usage analytics objects per user.
   */
  @AuraEnabled(cacheable=true)
  public static List<UserGenerationStats> getUserGenerationSummary() {
    // ---------------------------------------------------------
    // Access Control: Only return analytics for authorized users
    // ---------------------------------------------------------
    if (!userHasAnalyticsAccess()) {
      throw new AuraHandledException(
        'You do not have permission to view AI Customer Summary Report.'
      );
    }

    // Query all GenAI Gateway requests from the last 30 days for IndustriesSummarization
    List<GenAIGatewayRequest__dlm> gatewayRequests = [
      SELECT Id, userId__c, timestamp__c, feature__c, numGenerations__c
      FROM GenAIGatewayRequest__dlm
      WHERE
        timestamp__c >= LAST_N_DAYS:30
        AND feature__c = 'IndustriesSummarization'
    ];

    // Collect valid User Ids
    Set<Id> userIds = new Set<Id>();
    for (GenAIGatewayRequest__dlm req : gatewayRequests) {
      if (req.userId__c != null && req.userId__c != 'NOT_SET') {
        try {
          userIds.add(Id.valueOf(req.userId__c));
        } catch (Exception e) {
          // Ignore invalid User Id formats
        }
      }
    }

    // Pull User Name + User Segment
    Map<Id, User> userMap = new Map<Id, User>(
      [
        SELECT Id, Name, Commercial_Segment__c
        FROM User
        WHERE Id IN :userIds
      ]
    );

    Map<Id, UserGenerationStats> resultMap = new Map<Id, UserGenerationStats>();

    Datetime sevenDaysAgo = System.now().addDays(-7);
    Datetime thirtyDaysAgo = System.now().addDays(-30);

    for (GenAIGatewayRequest__dlm req : gatewayRequests) {
      // Ensure a wrapper exists for this user
      if (!resultMap.containsKey(req.userId__c)) {
        User u = userMap.get(req.userId__c);

        UserGenerationStats stats = new UserGenerationStats();
        stats.userId = req.userId__c;
        stats.userName = (u != null ? u.Name : 'Unknown');
        stats.userSegment = (u != null ? u.Commercial_Segment__c : 'Unknown');

        resultMap.put(req.userId__c, stats);
      }

      UserGenerationStats statsRecord = resultMap.get(req.userId__c);

      // Convert numGenerations safely
      Integer genCount = req.numGenerations__c != null
        ? Integer.valueOf(req.numGenerations__c)
        : 0;

      // Weekly totals
      if (req.timestamp__c >= sevenDaysAgo) {
        statsRecord.weeklyGenerationCount += genCount;
      }

      // Monthly totals
      if (req.timestamp__c >= thirtyDaysAgo) {
        statsRecord.monthlyGenerationCount += genCount;
      }

      // Latest timestamp
      if (
        statsRecord.lastGeneratedTime == null ||
        req.timestamp__c > statsRecord.lastGeneratedTime
      ) {
        statsRecord.lastGeneratedTime = req.timestamp__c;
      }
    }

    return resultMap.values();
  }
}
