/**
 * @description data model to delete an income from SOP through api
 * @author @fangl6(Lei Fang)
 * @since Sep 2023
 * @group Models
 */
public class SOPDeleteIncomeModel {
  public String name;
  public String etag;

  /**
   * @param json input string to deserialize
   * @return `SOPDeleteIncomeModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static SOPDeleteIncomeModel parse(String json) {
    SOPDeleteIncomeModel model = (SOPDeleteIncomeModel) System.JSON.deserialize(
      json,
      SOPDeleteIncomeModel.class
    );
    return model;
  }
}
