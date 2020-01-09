/**
 * 
 * @author Pavan Kuamr Ananta
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description MockHttpCapService is a CAP mock service which is used to send mock responses for 
 * various test scenarios for Customer Profile Information HTTP callout.
 */
public class MockHttpCapService implements HttpCalloutMock {
Exception callException = null;
Integer statusCode = null;
String responseBody = null;
/**
 * @description MockHttpCapService constructor
 * @param statusCode 
 * @param responseBody 
 */
public MockHttpCapService(Integer statusCode, String responseBody) {
    this.statusCode = statusCode;
	this.responseBody = responseBody;
}
/**
 * @description MockHttpCapService constructor
 * @param callException 
 */
public MockHttpCapService(Exception callException) {
	this.callException = callException;
}
/**
 * @description Mock the response to the requests from Test classes
 * @param req 
 * @return `HTTPResponse`
 */
public HTTPResponse respond(HTTPRequest req) {
	System.assertEquals('GET', req.getMethod());
	if (callException == null) {
		// Create a fake response
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(responseBody);
		res.setStatusCode(statusCode);
		return res;
	} else {
		throw callException;
	}
}
}
