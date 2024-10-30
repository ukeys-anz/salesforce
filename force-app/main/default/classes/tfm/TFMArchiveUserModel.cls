/**
 * @author Akshat Khandelwal
 * @since May 2024
 * @description Model class to parse archive user API response
 * @group TFM
 */
public with sharing class TFMArchiveUserModel extends CalloutModel {
  public String totalConsents;
  public String totalActiveConsents;
  public String unsuccessfullyArchivedConsents;
  public String successfullyArchivedConsents;
  public String archivedUserResponse;
  /**
   * @description Represents Response body for archive user API
   * @param json json response from archive user API
   * @return `ArchiveUser` api response is serialised into TFMArchiveUserModel
   */
  public static TFMArchiveUserModel parse(String json) {
    return (TFMArchiveUserModel) deserialize(json, TFMArchiveUserModel.class);
  }
}