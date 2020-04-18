/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group faker
 * @description  Factory factory interface.
 */
public interface FakerFactoryInterface {
  /**
   * @description objectName() interface method
   * @return `String`
   */
  String objectName();

  /**
   * @description getLocale() interface method
   * @return `String`
   */
  String getLocale();

  /**
   * @description define() interface method
   * @return `String`
   */
  Map<String, Object> define();
}
