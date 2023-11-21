/**
 * @description helper class for creating and handling exception
 * @author @fangl6(Lei Fang)
 * @since Nov 2023
 */
public class ExceptionHelper {
  /**
   * @description AuraHandledException expect parameter however it doesn't do anything
   * use setMessage to set custom message
   * @param errorMessage custom error message for exception
   * @return  `AuraHandledException`
   */
  public static AuraHandledException createAuraHandledException(
    String errorMessage
  ) {
    AuraHandledException e = new AuraHandledException(errorMessage);
    e.setMessage(errorMessage);
    return e;
  }
}
