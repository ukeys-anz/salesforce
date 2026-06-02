/**
 * @author Ayushi Gupta
 * @since  03/2026
 * @group Platform
 * @description ARNC360ServiceMock class is a mock implementation of ARNC360Service which returns predefined responses for different endpoints. It is used for testing purposes to simulate API responses without making actual callouts.
 */
public with sharing class ARNC360ServiceMock extends ARNC360Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public ARNC360ServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param calloutRequest calloutRequest
   * @return HttpCalloutResponse the api response
   * @description does mock callout of cache accounts
   */
  public override HttpCalloutResponse queryExternalData(
    ExternalObjectQueryBase.ExternalObjectCalloutRequestBase calloutRequest
  ) {
    if (!preset) {
      String endPointUrl = calloutRequest.getEndpoint();
      switch on endPointUrl {
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/ListCacheAssetFinanceAmbitContracts' {
          response.body = Service.getStaticResource('mock_contract');
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/GetCacheAssetFinanceAmbitContract' {
          response.body = Service.getStaticResource(
            'mock_contractDetailResponse'
          );
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/ListCacheAssetFinanceAmbitCreditLines' {
          response.body = Service.getStaticResource('mock_assetFinanceAMBIT');
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/GetCacheAssetFinanceAmbitCreditLine' {
          response.body = Service.getStaticResource(
            'mock_AmbitCreditLineDetail'
          );
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/ListCacheAssetFinanceAmbitAssets' {
          response.body = Service.getStaticResource('mock_assetDetail');
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/GetCacheAssetFinanceAmbitAsset' {
          response.body = Service.getStaticResource(
            'mock_assetDetalForDetailView'
          );
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/ListCacheAssetFinanceAmbitRepayments' {
          response.body = Service.getStaticResource(
            'mock_assetRepaymentDetail'
          );
        }
        when 'callout:Secure_waf_gw/salesforce.service.financialaccount.v1alpha1.CacheFinancialAccountAPI/ListCacheAssetFinanceAmbitRelationships' {
          response.body = Service.getStaticResource('mock_accountRelationship');
        }
      }
    }
    return response;
  }
}
