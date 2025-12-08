/**
 * @author duttp5
 * @since Nov 2025
 * @description Test class for GenAIAnalyticsService
 */
@IsTest
private class GenAIAnalyticsServiceTest {
  @IsTest
  static void testGetUserGenerationSummaryUsingSoqlStub() {
    // 0. Assign required Permission Set to test user
    // Get the Permission Set
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'GenieUserEnhancedSecurity'
      LIMIT 1
    ];

    // Check whether the test user already has this permission set
    List<PermissionSetAssignment> existingPSA = [
      SELECT Id
      FROM PermissionSetAssignment
      WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId = :ps.Id
    ];

    // Insert only if not present
    if (existingPSA.isEmpty()) {
      insert new PermissionSetAssignment(
        AssigneeId = UserInfo.getUserId(),
        PermissionSetId = ps.Id
      );
    }

    // 1. Register stub
    SoqlStubProvider stub = new GenAIGatewayRequestStub();
    Test.createSoqlStub(GenAIGatewayRequest__dlm.sObjectType, stub);

    System.assert(
      Test.isSoqlStubDefined(GenAIGatewayRequest__dlm.sObjectType),
      'SOQL stub should be registered for GenAIGatewayRequest__dlm'
    );

    // 2. Real user
    User u = [
      SELECT Id, Name, Commercial_Segment__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];

    // 3. Execute
    Test.startTest();
    List<GenAIAnalyticsService.UserGenerationStats> results = GenAIAnalyticsService.getUserGenerationSummary();
    Test.stopTest();

    // 4. Assertions
    System.assertEquals(1, results.size(), 'One user expected');

    GenAIAnalyticsService.UserGenerationStats stats = results[0];

    System.assertEquals(u.Id, stats.userId, 'User Id should match');
    System.assertEquals(u.Name, stats.userName, 'User Name should match');
    System.assertEquals(
      u.Commercial_Segment__c,
      stats.userSegment,
      'Segment should match'
    );

    System.assertEquals(
      2,
      stats.weeklyGenerationCount,
      'Weekly count incorrect'
    );

    System.assertEquals(
      7,
      stats.monthlyGenerationCount,
      'Monthly count incorrect'
    );

    System.assertNotEquals(
      null,
      stats.lastGeneratedTime,
      'Timestamp should not be null'
    );
  }

  // =====================================================================
  //                         STUB PROVIDER
  // =====================================================================
  private class GenAIGatewayRequestStub extends SoqlStubProvider {
    public override List<SObject> handleSoqlQuery(
      SObjectType sot,
      String query,
      Map<String, Object> bindVars
    ) {
      System.assertEquals(
        GenAIGatewayRequest__dlm.sObjectType,
        sot,
        'Stub must only serve GenAIGatewayRequest__dlm queries'
      );

      // Retrieve current UserId used inside the service
      String userId = UserInfo.getUserId();

      // -------------------------------------
      // Build two mock DMO rows
      // -------------------------------------
      // Row 1: Within last 7 days → weekly + monthly
      GenAIGatewayRequest__dlm row1 = (GenAIGatewayRequest__dlm) Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'Id' => 'a0000000001AAA',
          'userId__c' => userId,
          'timestamp__c' => System.now().addDays(-3),
          'feature__c' => 'IndustriesSummarization',
          'numGenerations__c' => 2
        }
      );

      // Row 2: Within last 30 days → monthly only
      GenAIGatewayRequest__dlm row2 = (GenAIGatewayRequest__dlm) Test.createStubQueryRow(
        sot,
        new Map<String, Object>{
          'Id' => 'a0000000002AAA',
          'userId__c' => userId,
          'timestamp__c' => System.now().addDays(-12),
          'feature__c' => 'IndustriesSummarization',
          'numGenerations__c' => 5
        }
      );

      return new List<SObject>{ row1, row2 };
    }
  }
}
