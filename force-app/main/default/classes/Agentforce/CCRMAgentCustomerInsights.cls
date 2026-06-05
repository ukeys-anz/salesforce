/**
 * @author Prasanjeet
 * @since 2026
 * @description Invocable class that retrieves Customer, WOC, and BBD insights.
 */
public with sharing class CCRMAgentCustomerInsights {
  private static final CCRMAgentBQRepository REPO = (CCRMAgentBQRepository) Lib_InstanceProvider.forType(
    CCRMAgentBQRepository.class
  );

  private static final CCRMAgentforceRepository AGENT_REPO = (CCRMAgentforceRepository) Lib_InstanceProvider.forType(
    CCRMAgentforceRepository.class
  );

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static final String SCOPE_SINGLE = 'SINGLE';
  private static final String SCOPE_PORTFOLIO = 'PORTFOLIO';
  private static final String CPID_TYPE_P = 'P';
  private static final String CPID_TYPE_R = 'R';

  /**
   * @description Input wrapper for invocable method.
   */
  public class Request {
    @InvocableVariable(required=false)
    public Id accountId;

    @InvocableVariable(required=true)
    public String scope;
  }

  /**
   * @description Output wrapper returned to Agent.
   */
  public class Response {
    @InvocableVariable
    public List<CustomerInsightsWrapper> customerAndWocInsights;

    @InvocableVariable
    public List<BusinessBankerDesktop__dlm> bbdInsights;
  }

  /**
   * @description Per-customer grouped insights container.
   */
  public class CustomerInsightsWrapper {
    @InvocableVariable
    public String customerId;

    @InvocableVariable
    public String customerNumber;

    @InvocableVariable
    public String customerName;

    @InvocableVariable
    public List<Customer_Insights__dlm> customerInsights;

    @InvocableVariable
    public List<WholeOfCustomer__dlm> wocInsights;
  }

  /**
   * @description Internal container for customer number sets.
   */
  private class CustomerNumberSetWrapper {
    public Set<String> customerNumberStrSet = new Set<String>();
    public Set<Decimal> customerNumberDecSet = new Set<Decimal>();
  }

  /**
   * @description Entry point to fetch customer insights.
   * @param requestList List of Request containing accountId and scope
   * @return List<Response> grouped insights response
   */
  @InvocableMethod(label='Get Customer Insights By Account')
  public static List<Response> getCustomerInsights(List<Request> requestList) {
    Response res = initResponse();

    if (requestList == null || requestList.isEmpty()) {
      return new List<Response>{ res };
    }

    Request req = requestList[0];

    CustomerNumberSetWrapper custWrapper = resolveCustomerNumbers(
      req.accountId,
      req.scope
    );

    // Fetch BBD insights based on lanId regardless of customer numbers
    res.bbdInsights = fetchBBDInsights();

    if (custWrapper.customerNumberStrSet.isEmpty()) {
      return new List<Response>{ res };
    }

    Map<String, CustomerInsightsWrapper> wrapperMap = initializeCustomerWrappers(
      custWrapper
    );

    attachCustomerInsights(wrapperMap, custWrapper);
    attachWOCInsights(wrapperMap, custWrapper);

    res.customerAndWocInsights.addAll(wrapperMap.values());

    return new List<Response>{ res };
  }

  /**
   * @description Resolves customer numbers based on UI context.
   * @param accountId Salesforce Account Id (required for SINGLE scope, optional for Portfolio)
   * @param scope UI context scope (SINGLE or Portfolio)
   * @return CustomerNumberSetWrapper set of resolved customer numbers
   */
  private static CustomerNumberSetWrapper resolveCustomerNumbers(
    Id accountId,
    String scope
  ) {
    CustomerNumberSetWrapper wrapper = new CustomerNumberSetWrapper();

    if (scope == SCOPE_SINGLE) {
      // SINGLE scope requires accountId
      if (accountId == null) {
        return wrapper;
      }

      List<Account> accList = AGENT_REPO.fetchAccountById(accountId);

      if (accList.isEmpty()) {
        return wrapper;
      }

      Account acc = accList[0];

      if (acc.RecordTypeId != RTAccount.clgAccount) {
        return wrapper;
      }

      addCustomer(wrapper, acc.Source_System_ID__c);
      return wrapper;
    }

    // Portfolio scope - fetch CPID from Controlling_Post__c based on user's Lan_Id__c
    String lanId = USER_INFO.getUser().Lan_Id__c;

    if (String.isBlank(lanId)) {
      return wrapper;
    }

    List<Controlling_Post__c> controllingPosts = AGENT_REPO.fetchControllingPostByLanId(
      lanId
    );

    if (controllingPosts.isEmpty()) {
      return wrapper;
    }

    Controlling_Post__c controllingPost = controllingPosts[0];

    // Check if CPID Type is 'P' or 'R'
    if (
      controllingPost.CPID_Type__c == CPID_TYPE_P ||
      controllingPost.CPID_Type__c == CPID_TYPE_R
    ) {
      for (Account a : AGENT_REPO.fetchCLGAccountsByCPID(controllingPost.Id)) {
        addCustomer(wrapper, a.Source_System_ID__c);
      }
    }

    return wrapper;
  }

  /**
   * @description Initializes wrapper map for all resolved customers.
   * @param custWrapper customer number set wrapper
   * @return Map keyed by customer number
   */
  private static Map<String, CustomerInsightsWrapper> initializeCustomerWrappers(
    CustomerNumberSetWrapper custWrapper
  ) {
    Map<String, CustomerInsightsWrapper> wrapperMap = new Map<String, CustomerInsightsWrapper>();
    Map<String, Account> accountMap = fetchAccountMap(
      custWrapper.customerNumberStrSet
    );

    for (String custNum : custWrapper.customerNumberStrSet) {
      CustomerInsightsWrapper w = new CustomerInsightsWrapper();
      w.customerNumber = custNum;
      w.customerInsights = new List<Customer_Insights__dlm>();
      w.wocInsights = new List<WholeOfCustomer__dlm>();

      if (accountMap.containsKey(custNum)) {
        w.customerName = accountMap.get(custNum).Name;
        w.customerId = accountMap.get(custNum).Id;
      }

      wrapperMap.put(custNum, w);
    }

    return wrapperMap;
  }

  /**
   * @description Attaches customer insight records to wrappers.
   * @param wrapperMap map of customer wrappers
   * @param custWrapper customer number set
   */
  private static void attachCustomerInsights(
    Map<String, CustomerInsightsWrapper> wrapperMap,
    CustomerNumberSetWrapper custWrapper
  ) {
    List<Customer_Insights__dlm> allInsights = REPO.fetchCustomerInsights(
      custWrapper.customerNumberDecSet
    );

    for (Customer_Insights__dlm rec : allInsights) {
      String key = normalizeDecimalKey(rec.customer_no__c);

      if (wrapperMap.containsKey(key)) {
        wrapperMap.get(key).customerInsights.add(rec);
      }
    }
  }

  /**
   * @description Attaches WOC insight records to wrappers.
   * @param wrapperMap customer wrapper map
   * @param custWrapper customer number set
   */
  private static void attachWOCInsights(
    Map<String, CustomerInsightsWrapper> wrapperMap,
    CustomerNumberSetWrapper custWrapper
  ) {
    List<WholeOfCustomer__dlm> allWoc = REPO.fetchWOCInsights(
      custWrapper.customerNumberStrSet
    );

    for (WholeOfCustomer__dlm rec : allWoc) {
      String key = rec.bus_cust_no__c;

      if (wrapperMap.containsKey(key)) {
        wrapperMap.get(key).wocInsights.add(rec);
      }
    }
  }

  /**
   * @description Fetches BBD insights for logged-in user.
   * @return list of BBD insights
   */
  private static List<BusinessBankerDesktop__dlm> fetchBBDInsights() {
    String lanId = USER_INFO.getUser().Lan_Id__c;

    if (String.isBlank(lanId)) {
      return new List<BusinessBankerDesktop__dlm>();
    }

    return REPO.fetchBBDInsights(lanId);
  }

  /**
   * @description Initializes empty response object
   * @return Response initialized response
   */
  private static Response initResponse() {
    Response res = new Response();
    res.customerAndWocInsights = new List<CustomerInsightsWrapper>();
    res.bbdInsights = new List<BusinessBankerDesktop__dlm>();
    return res;
  }

  /**
   * @description Fetch account map by customer numbers
   * @param custNums set of customer numbers
   * @return map of customer number to Account
   */
  private static Map<String, Account> fetchAccountMap(Set<String> custNums) {
    Map<String, Account> result = new Map<String, Account>();

    for (Account a : AGENT_REPO.fetchAccountsByCustomerNumbers(custNums)) {
      result.put(a.Source_System_ID__c, a);
    }

    return result;
  }

  /**
   * @description Adds customer number to wrapper sets
   * @param wrapper customer set wrapper
   * @param custNum customer number string
   */
  private static void addCustomer(
    CustomerNumberSetWrapper wrapper,
    String custNum
  ) {
    if (String.isNotBlank(custNum)) {
      wrapper.customerNumberStrSet.add(custNum);
      wrapper.customerNumberDecSet.add(Decimal.valueOf(custNum));
    }
  }

  /**
   * @description Normalize decimal key to string
   * @param value decimal customer number
   * @return normalized string key
   */
  private static String normalizeDecimalKey(Decimal value) {
    String key = String.valueOf(value);
    return key.contains('.') ? key.substring(0, key.indexOf('.')) : key;
  }
}
