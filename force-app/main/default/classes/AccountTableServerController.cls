/**
 *
 * @author Lance Shi
 * @since 2020
 * @description AccountTableServerController is apex side controller for AccountTable LWC
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public class AccountTableServerController {
  /**
   * @description Currently the Account record page has a lwc which needs to fetch the account information on demand on a account record page based on ocvid.
   * This api call is made to mulesoft to fetch the required customer information.
   *
   * @return `String`
   */
  private static String callAccService() {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String ocvid = '123';
    request.setEndpoint('callout:Mulesoft' + Label.MS_Account_Table + ocvid);
    request.setMethod('GET');

    HttpResponse response = http.send(request);
    return response.getBody();
  }

  /**
   * @description Currently the Account record page has a lwc which needs to fetch the account information on demand on a account record page based on CAP SIS ID.
   * This api call is made to mulesoft to fetch the required customer information.
   * {@link Lib_SystemLog.logAPIError} is called when ever the call fails to cap to have the logs recorded for monitoring.
   *
   * @return `List<AccountInfo>`
   * @exception AuraHandledException
   */
  @AuraEnabled(cacheable=false)
  public static List<AccountInfo> getAccInfo() {
    AccountInfoWrapper accInfoListwrapper = new AccountInfoWrapper();
    String resp = '';
    try {
      resp = callAccService();
      accInfoListwrapper = (AccountInfoWrapper) JSON.deserialize(
        resp,
        AccountInfoWrapper.class
      );
    } catch (Exception e) {
      Lib_SystemLog.logAPIError(
        AccountTableServerController.class.getName(),
        'getAccInfo',
        e.getMessage(),
        e.getTypeName(),
        AccountTableServerController.class.getName(),
        null,
        resp
      );
      AuraHandledException ahe = new AuraHandledException(e.getMessage());
      ahe.setMessage(e.getMessage());
      throw ahe;
    }
    List<AccountInfo> returnedAccountList = accInfoListwrapper.account_list;
    for (AccountInfo accInfo : returnedAccountList) {
      DateTime balanceDate = (DateTime) Json.deserialize(
        '"' +
        accInfo.balance_valid_asof +
        '"',
        DateTime.class
      );
      accInfo.balance_valid_asof = balanceDate.format();
    }
    return returnedAccountList;
  }

  /**
	@description wrapper class of the mulesoft response
  */
  public class AccountInfoWrapper {
    @AuraEnabled
    public List<AccountInfo> account_list;
  }

  /**
	@description wrapper class of the account information
  */
  public class AccountInfo {
    @AuraEnabled
    public String account_number;
    @AuraEnabled
    public String bsb;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public BalanceInfo balance;
    @AuraEnabled
    public String balance_valid_asof;
  }

  /**
	@description wrapper class of the balance information
  */
  public class BalanceInfo {
    @AuraEnabled
    public String currency_code;
    @AuraEnabled
    public String value;
  }
}
