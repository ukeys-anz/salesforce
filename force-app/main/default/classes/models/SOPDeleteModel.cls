/**
 * @description data model to delete income,debt from SOP through api
 * @author @fangl6(Lei Fang)
 * @since April 2024
 * @group Models
 */
public class SOPDeleteModel {
  public String name;
  public String etag;

  /**
   * @param json input string to deserialize
   * @return `SOPDeleteModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPDeleteModel parse(String json) {
    SOPDeleteModel model = (SOPDeleteModel) System.JSON.deserialize(
      json,
      SOPDeleteModel.class
    );
    return model;
  }
}
