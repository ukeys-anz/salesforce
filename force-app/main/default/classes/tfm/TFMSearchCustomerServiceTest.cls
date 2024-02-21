/**
 * @author Hinduja Upadhyay
 * @since JAN 2024
 * @description Test class for {@link TFMSearchCustomerService}
 * @group Services
 */
@isTest
public inherited sharing class TFMSearchCustomerServiceTest {
  private static final String SUCCESS_SEARCH_CUSTOMER =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';
  @isTest
  static void testgetValidStaffToken() {
    String token = 'eyJ0eXAiOiJKV1QiLCJraWQiOiJmSzJIU041anVFT1B6SXpsdmppZzUxdnFHRVU9IiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJhZWdpc191c2VyMkBhbnpucC5jb20iLCJjdHMiOiJPQVVUSDJfU1RBVEVMRVNTX0dSQU5UIiwiYXVkaXRUcmFja2luZ0lkIjoiNDIzNjM2YTEtMTNmMC00MWRiLTg1MTUtMzZhYjM2ODY1Y2I1LTY3NjUzMCIsInN1Ym5hbWUiOiJzcGEtZWEiLCJpc3MiOiJodHRwczovL2lkZW50aXR5LXNlcnZpY2VzLXNpdC1pbnQtZ3cuYXBwcy1pbnQueC5nY3BucC5hbnovYW0vb2F1dGgyL2N1c3RvbWVyIiwidG9rZW5OYW1lIjoiYWNjZXNzX3Rva2VuIiwidG9rZW5fdHlwZSI6IkJlYXJlciIsImF1dGhHcmFudElkIjoiclp2WFZLZVhNZWhxZUh1N1hMZGJYSmh1RE13IiwiYXVkIjoic3BhLWVhIiwibmJmIjoxNzA0Nzg0MjA5LCJncmFudF90eXBlIjoiY2xpZW50X2NyZWRlbnRpYWxzIiwic2NvcGUiOiJhZWdpcy1pbnRyb3NwZWN0IGF1X2FuenhfZnJhdWR4X29wc19hZG1pbiIsImF1dGhfdGltZSI6MTcwNDc4NDIwOSwicmVhbG0iOiIvY3VzdG9tZXIiLCJleHAiOjE3MDQ3ODc4MDksImlhdCI6MTcwNDc4NDIwOSwiZXhwaXJlc19pbiI6MzYwMCwianRpIjoickp0c3JLQ0hzSDdwa1RzZHFab2JNYnNWZlRvIiwicnFmIjp7InN1YiI6IjdmNzcyYzJkLTljMjUtNDFhZi05YWY3LTU0ZGY2ODZhY2JjNCIsInBlcnNvbmEiOnsiX2lkIjoiYmRiNTcyYzgtNGJlZS00ZDMwLWI2MTQtODk3MGY3ODQ4Y2I3IiwidHlwZSI6InJldGFpbCJ9LCJvY3ZpZCI6IjEwMDEwODg3MDMifSwiYWNyIjoiSUFMNC5BQUwzLkZBTDIiLCJhY3QiOnsic3ViIjoic3BhLWVhIn0sImFtciI6WyJwd2QiXSwiYW56X3Rva2VuX3R5cGUiOiJzdGFmZlJxZkN1c3RvbWVyIiwibm9uY2UiOiJlOWUwOTQ1NzM3Iiwic2NvcGVzIjpbImFlZ2lzLWludHJvc3BlY3QiLCJhdV9hbnp4X2ZyYXVkeF9vcHNfYWRtaW4iXX0.FAYZYwnrTjzKSlNDNhjWe--d4qOr8WcsAdFlkeisCnj1ZS4-7mkG7GKtSHbl8vNj0IhsQKKvnIHF0fceCiZjMXLqUOE-if_-BJYWvEoLqHqMh5CLFne9EiJfRIzScZyiYqR8gvVg4GPn8FExRHr-Ct1LSUNqI9PM-7O2hui11sOfCzpifsNW83cTnHingiOWpkKQdzDVYRORN_rAPQgqM6cx1kUk5Lqme8fqU64qC8QMedNaHVEbHctcJuIW_JwgQfeeJBhPORuKdnR75k2f9zPUFZwrqYCqzeOPFhprAEnfASn2J8y6F6cNSunHw1zff9U-F4X6cZtZlUe7Xxs0OA';
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    Map<String, String> headers = new Map<String, String>();
    staffModel.headers = headers;
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = '1111';
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.action = 'SearchCustomer';
    staffModel.headers.put('Authorization', token);
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    headers = service.getValidStaffToken(staffModel);
    Test.stopTest();
    Assert.areNotEqual(headers, null, 'headers not null');
  }

  @isTest
  static void testsearchCustAPI() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    Map<String, String> headers = new Map<String, String>();
    staffModel.headers = headers;
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = '1111';
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.action = 'SearchCustomer';

    Test.setMock(HttpCalloutMock.class, new MockSerachCustomerResponse());
    Test.startTest();
    TFMSearchCustomerService service = new TFMSearchCustomerService();
    HttpCalloutResponse response = service.searchCustAPI(staffModel);

    Test.stopTest();
    Assert.areNotEqual(
      response.body,
      null,
      'Response body should not be null.'
    );
  }

  class MockSerachCustomerResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(SUCCESS_SEARCH_CUSTOMER);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
