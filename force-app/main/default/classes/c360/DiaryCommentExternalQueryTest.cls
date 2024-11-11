/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of DiaryCommentExternalQuery
 */
@isTest
private class DiaryCommentExternalQueryTest {
  @isTest
  static void createDiaryCommentTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new DiaryCommentTestMock());
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'DiaryComment'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    DiaryCommentExternalQuery accountQuery = new DiaryCommentExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of comments is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
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
    DiaryCommentExternalQuery instance = new DiaryCommentExternalQuery();
    String fsResult = instance.formatSequence(1);
    Test.stopTest();
    Assert.areEqual('0001', fsResult, 'Incorrect sequence formatting');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class DiaryCommentTestMock implements HttpCalloutMock {
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
