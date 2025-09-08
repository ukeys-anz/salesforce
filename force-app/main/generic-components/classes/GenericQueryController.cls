/**
 * @description Generic query controller to handle SOQL queries. Controllers must implement the Callable interface.
 * @author Peter Charalambous
 * @since 07/2025
 */
public with sharing class GenericQueryController implements IGenericClass {
  private static final String ERROR_MSG = 'Something went wrong. Please refresh and try again. Raise a fault through TechAssist if the problem persists.';

  /**
   * @description getData method to return SOQL data
   * @param param String parameter containing JSON with controller, method, and args
   *             Example: {"controller": "AccountQueryController", "method": "getAccountByOcvId", "args": {"ocvId": "12345"}}
   * @return Object Array of Data
   */
  public Object getData(String param) {
    try {
      Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(
        param
      );
      String controllerName = (String) params.get('controller');
      String methodName = (String) params.get('method');
      Map<String, Object> args = (Map<String, Object>) params.get('args');

      if (String.isBlank(controllerName) || String.isBlank(methodName)) {
        Logger.info(
          'Failure on GenericQueryController.getData, controller or method missing'
        );
        Logger.saveLog();
        throw new AuraHandledException(ERROR_MSG);
      }

      // Dynamically instantiate the controller
      Object controller = Lib_InstanceProvider.forType(
        Type.forName(controllerName)
      );

      //Controller needs to implement Callable
      if (controller instanceof Callable) {
        return ((Callable) controller).call(methodName, args);
      } else {
        Logger.info(
          'Failure on GenericQueryController.getData, controller not implementing Callable: ' +
          controllerName
        );
        Logger.saveLog();
        throw new AuraHandledException(ERROR_MSG);
      }
    } catch (Exception e) {
      Logger.error('Failure on GenericQueryController.getData', e);
      Logger.saveLog();
      AuraHandledException err = new AuraHandledException(ERROR_MSG);
      err.setMessage(ERROR_MSG);
      throw err;
    }
  }
}
