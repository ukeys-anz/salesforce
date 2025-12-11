/**
 * @description controller class for genericSection lwc
 * @depends IGenericClass, StaticResource
 * @author @PV
 * @since 11/2024
 */
public with sharing class GenericController {
  private static final String ERROR_MSG = 'Failed to retrieve the value.';
  /**
   * @description generic method to get layout configuration
   * @param configName Static Resource JSON for Config
   * @return String JSON configuration
   */
  @AuraEnabled
  public static String getConfig(String configName) {
    try {
      if (String.isBlank(configName)) {
        throw new IllegalArgumentException('No configuration found');
      }
      StaticResource sr;
      if (StaticResource.sObjectType.getDescribe().isQueryable()) {
        sr = [
          SELECT body
          FROM StaticResource
          WHERE Name = :configName
          WITH USER_MODE
          LIMIT 1
        ];
        return sr.body?.toString();
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    return null;
  }
  /**
   * @description generic method to get data based on GenericClass implementation
   * @param apexController Class to instantiate
   * @param param Parameter to pass to the getData method
   * @return Object returned by the getData method
   */
  @AuraEnabled
  public static Object getData(String apexController, String param) {
    try {
      if (String.isBlank(apexController)) {
        throw new IllegalArgumentException('No ApexController defined');
      }
      // Get the Type corresponding to the class name
      Type tclass = Type.forName(apexController);
      // Instantiate the type.
      IGenericClass getDataClass = (IGenericClass) tclass.newInstance();
      // Execute getData
      return getDataClass.getData(param);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description generic method to update data based on GenericClass implementation
   * @param apexController Class to instantiate
   * @param param Parameter to pass to the updateData method
   */
  @AuraEnabled
  public static void updateData(String apexController, String param) {
    try {
      if (String.isBlank(apexController)) {
        throw new IllegalArgumentException('No ApexController defined');
      }
      // Get the Type corresponding to the class name
      Type tclass = Type.forName(apexController);
      // Instantiate the type.
      IGenericModify getDataClass = (IGenericModify) tclass.newInstance();
      // Execute updateData
      getDataClass.updateData(param);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
