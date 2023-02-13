/**
 * @author Lance Shi
 * @since  01/2023
 * @description Wrapper Class for Cloud Events
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions'
)
public virtual with sharing class CloudEventModel {
  public String ce_specversion { get; set; }
  public String ce_type { get; set; }
  public String ce_source { get; set; }
  public String ce_subject { get; set; }
  public String ce_id { get; set; }
  public DateTime ce_time { get; set; }
  public String ce_datacontenttype { get; set; }
  public String ce_dataschema { get; set; }
  public String ce_partitionkey { get; set; }
  public DateTime ce_xpartitionedkeysequence { get; set; }
  public String ce_xtargets { get; set; }
  public String ce_traceparent { get; set; }
  public CloudEventSystemModel system_data { get; set; }
  public CloudEventDataModel ce_data { get; set; }

  public CloudEventModel() {
    this.ce_specversion = '1.0';
    this.ce_time = DateTime.now();
    this.ce_xpartitionedkeysequence = DateTime.now();
    this.ce_datacontenttype = 'application/json';
  }

  /**
   * @description the model for cloud event data part
   */
  public virtual class CloudEventDataModel {
    public String recordId { get; set; }
    public CloudEventDataModel(SObject theRecord) {
      this.recordId = theRecord.Id;
    }
  }

  /**
   * @description the model for cloud event system data part
   */
  public class CloudEventSystemModel {
    public UserModel lastModifiedByUser { get; set; }
    public Datetime lastModifiedTime { get; set; }

    public CloudEventSystemModel(Datetime modifiedTime, User relatedUser) {
      this.lastModifiedByUser = new UserModel(relatedUser);
      this.lastModifiedTime = modifiedTime;
    }
  }

  /**
   * @description Wrapper Class for a user or a group
   */
  public virtual class UserModel {
    public String recordId { get; set; }
    public String name { get; set; }
    public String email { get; set; }

    public UserModel(User theUser) {
      this.recordId = theUser?.Id;
      this.name = theUser?.UserName;
      this.email = theUser?.Email;
    }

    public UserModel(Group theQueue) {
      this.recordId = theQueue?.Id;
      this.name = theQueue?.Name;
      this.email = theQueue?.Email;
    }
  }
}
