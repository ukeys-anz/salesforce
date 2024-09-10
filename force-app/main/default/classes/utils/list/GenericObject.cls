/**
 * @author Tan Phan
 * @since 08/2024
 * @description The GenericObject interface represents a generic object whose fields can be retrieved dynamically.
 * @group Utils
 */
public interface GenericObject {
  /**
   * @description Retrieves the value of the specified field from the object.
   * @param fieldName The name of the field to retrieve the value from.
   * @return The value of the specified field.
   */
  Object get(String fieldName);
}
