/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of CCRMDiaryCommentQuery
 */
@isTest
private class CCRMDiaryCommentQueryTest {
  @isTest
  static void createDiaryCommentTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMDiaryCommentQueryTest.CCRMDiaryCommentTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'DiaryComment'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMDiaryCommentQuery accountQuery = new CCRMDiaryCommentQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of comments is not 1'
    );
    Map<String, Object> firstRecord = result.queryResult[0];
    System.assertEquals(
      'TEST COMMENT CHECK',
      firstRecord.get('Description'),
      'Comment mismatch'
    );
  }

  /**
   * @description test method for formatSequence
   */
  @isTest
  static void formatSequenceTest() {
    Test.startTest();
    CCRMDiaryCommentQuery instance = new CCRMDiaryCommentQuery();
    String fsResult = instance.formatSequence(1);
    Test.stopTest();
    System.assertEquals('0001', fsResult, 'Incorrect sequence formatting');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMDiaryCommentTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_diaryCommentResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
