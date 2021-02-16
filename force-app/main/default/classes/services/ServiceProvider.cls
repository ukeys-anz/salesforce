/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description provider class that instantiates service classes (or mocks)
 */
public with sharing class ServiceProvider {
  private final static Non_Prod_Settings__c NON_PROD_SETTINGS = Non_Prod_Settings__c.getOrgDefaults();
  private static Map<String, Service> servicesMap = new Map<String, Service>();

  /**
   * @param apexType apex type for the service
   * @return `Service` constructed service
   * @description a typed getter for services
   */
  public static Service getService(Type apexType) {
    String className = apexType.getName();
    return getService(getActualClassName(className));
  }

  /**
   * @param className service to instantiate
   * @return `Service` the constructed service
   * @throws ServiceProviderException exception occurring when trying to load service
   * @description constructs a real or mocked service depending on custom setting
   */
  public static Service getService(String className) {
    Service s = servicesMap.get(className);
    if (s == null) {
      //instantiate the service class
      Type customType = Type.forName(className);
      if (customType == null) {
        throw new ServiceProviderException(
          'No Service class found called [' +
          className +
          ']'
        );
      }

      s = (Service) customType.newInstance();
      servicesMap.put(className, s);
    }
    return s;
  }

  private static String getActualClassName(String className) {
    if (Test.isRunningTest() || NON_PROD_SETTINGS.MockCallouts__c) {
      className = className + 'Mock';
    }
    return className;
  }

  /**
   * @author Pavan Kumar Ananta
   * @since Feb 2020
   * @description api service exception
   */
  public class ServiceProviderException extends Exception {
  }
}
