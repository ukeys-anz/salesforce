/**
 * @author Emma Bindi
 * @since November 2022
 * @description model for cfaas documents
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 * @group Models
 */
// Suppressing below warning as response returns snake case values, which triggers PMD warnings
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CFaaSDocumentModel extends CalloutModel {
  /**
   * @description the download url wrapper
   */
  public CFaaSDownloadUrl CFaaSDownloadUrl;

  public class CFaaSDownloadUrl {
    public String url;
    public String otp;
    public String name;
    public String fileID;
    public String extension;

    /**
     * @description set the content type based on extension using map
     */
    public String contentType {
      get {
        if (fileExtensionToMimeTypeMap.containsKey(this.extension)) {
          return fileExtensionToMimeTypeMap.get(this.extension);
        } else {
          return null;
        }
      }
      set;
    }
  }

  /**
   * @param json input string to deserialize
   * @return `CFaaSDocumentModel.CFaaSDownloadUrl`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static CFaaSDocumentModel.CFaaSDownloadUrl parseDownloadUrlResponse(
    String json
  ) {
    try {
      return (CFaaSDocumentModel.CFaaSDownloadUrl) deserialize(
        json,
        CFaaSDocumentModel.CFaaSDownloadUrl.class
      );
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw e;
    }
  }

  private static Map<String, String> fileExtensionToMimeTypeMap = new Map<String, String>{
    'txt' => 'text/plain',
    'text' => 'text/plain',
    'rtf' => 'text/rtf',
    'pdf' => 'application/pdf',
    'doc' => 'application/msword',
    'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'tiff' => 'image/tiff',
    'tif' => 'image/tiff',
    'jpeg' => 'image/jpeg',
    'jpg' => 'image/jpeg',
    'gif' => 'image/gif',
    'bmp' => 'image/bmp',
    'png' => 'image/png',
    'xls' => 'application/vnd.ms-excel',
    'xls' => 'application/octet-stream',
    'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt' => 'application/vnd.ms-powerpoint',
    'pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'csv' => 'text/csv',
    'zip' => 'application/zip'
  };
}
