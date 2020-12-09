/**
 * @author Aidan Majewski
 * @since 2020
 * @description myTrailhead assignments LWC controller, originally sourced from https://github.com/CSGAMERSServices/Trailhead-Badge-and-Mix-Assignments-LWC
 */
public with sharing class TH_Assignments {
  public static final Integer MAX_RESULTS = 255;
  public static final String DEFAULT_STATUS = 'Assigned';

  /** format for external ids */
  public static final String FORMAT_EXTERNAL_ID = '{0}-{1}';

  /** represents a completed trailhead assignment status */
  public static final String ASSIGNMENT_STATUS_COMPLETED = 'Completed';

  /** represents an undefined status */
  public static final String ASSIGNMENT_STATUS_UNDEFINED = '';

  /**
   * @description Internal class that represents a generalized Trailhead assignment - Badge or TrailMix, comparable to allow duedate sorting
   **/
  public class TrailheadEntry implements Comparable {
    /** Id of the user assignment **/
    @AuraEnabled
    public String id;
    /** Name of the Badge or Trailmix **/
    @AuraEnabled
    public String name;
    /** Status of the current assignment **/
    @AuraEnabled
    public String status;
    /** Due Date for the assignment **/
    @AuraEnabled
    public DateTime dueDate;
    /** # Days until Due **/
    @AuraEnabled
    public Integer numDaysUntilDue;
    /** URL of the Badge or Trailmix **/
    @AuraEnabled
    public String url;
    /** Icon of the Badge or Trailmix **/
    @AuraEnabled
    public String icon;
    /** Type of Entry (i.e. Badge or Trailmix) **/
    @AuraEnabled
    public String entryType;

    /**
     * @description Constructor consuming a Trailmix Assignment
     * @param uT user trailmix to construct an assignment entry
     **/
    public TrailheadEntry(trailheadapp__User_Trailmix__c uT) {
      this.id = uT.Id;
      this.name = uT.trailheadapp__Trailmix__r.Name;
      this.status = uT.trailheadapp__Status__c;
      this.dueDate = uT.trailheadapp__Due_At__c;
      this.url = uT.trailheadapp__Trailmix__r.trailheadapp__URL__c;
      this.icon = Label.th_trailhead_trail_icon;
      this.entryType = Label.th_TrailheadTypeTrailmix;
    }

    /**
     * @description Constructor consuming a Badge Assignment
     * @param uB user badge to construct an assignment entry
     **/
    public TrailheadEntry(trailheadapp__User_Badge__c uB) {
      this.id = uB.Id;
      this.name = uB.trailheadapp__Badge__r.Name;
      this.status = uB.trailheadapp__Status__c;
      this.dueDate = uB.trailheadapp__Due_Date__c;
      this.url = uB.trailheadapp__URL__c;
      this.icon = uB.trailheadapp__Badge__r.trailheadapp__Icon__c;
      this.entryType = Label.th_TrailheadTypeBadge;
    }

    /**
     * @description Calculate the number of days until the assignment is due
     * @param targetDate due date for the assignment
     * @return Integer number of days til duedate
     **/
    private Integer calculateDaysUntilDue(Date targetDate) {
      Integer results = 0;
      if (targetDate == null) {
        targetDate = Date.today();
      }
      if (this.dueDate != null) {
        results = targetDate.daysBetween(this.dueDate.date());
      }
      this.numDaysUntilDue = results;
      return results;
    }

    /**
     * @description Comparison method to allow collated sorting
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_comparable.htm
     * @param compareTo (Object)
     * @return Integer
     **/
    public Integer compareTo(Object compareTo) {
      TrailheadEntry compareToE = (TrailheadEntry) compareTo;
      if (dueDate == compareToE.dueDate) {
        return 0;
      }
      if (
        dueDate > compareToE.dueDate ||
        (dueDate == null &&
        compareToE.dueDate != null)
      ) {
        return 1;
      }
      return -1;
    }
  }

  /**
   *  @description Determines the collated collection of Badges and TrailMixes associated to the user.
   *  @param whichType (String [TYPE_BADGE|TYPE_TRAILMIX|TYPE_BOTH]) - the type of assignments to count.
   *  @return TrailheadEntry[] - collection of generalized Badges and TrailMixes
   **/
  @AuraEnabled(cacheable=true)
  public static TrailheadEntry[] getAllAssignedTrailEntries(string whichType) {
    TrailheadEntry[] results = new List<TrailheadEntry>{};

    // if both types are included, sort the entire list
    if (whichType == Label.th_TrailheadTypeBoth) {
      trailheadapp__User_Trailmix__c[] assignedT = getAssignedTrails(
        MAX_RESULTS
      );
      for (trailheadapp__User_Trailmix__c uT : assignedT) {
        TrailheadEntry entry = new TrailheadEntry(uT);
        results.add(entry);
      }

      trailheadapp__User_Badge__c[] assignedB = getAssignedBadges(MAX_RESULTS);
      for (trailheadapp__User_Badge__c uB : assignedB) {
        TrailheadEntry entry = new TrailheadEntry(uB);
        results.add(entry);
      }

      results.sort();
    } else if (whichType == Label.th_TrailheadTypeTrailmix) {
      trailheadapp__User_Trailmix__c[] assignedT = getAssignedTrails(
        MAX_RESULTS
      );
      for (trailheadapp__User_Trailmix__c uT : assignedT) {
        TrailheadEntry entry = new TrailheadEntry(uT);
        results.add(entry);
      }
    } else if (whichType == Label.th_TrailheadTypeBadge) {
      trailheadapp__User_Badge__c[] assignedB = getAssignedBadges(MAX_RESULTS);
      for (trailheadapp__User_Badge__c uB : assignedB) {
        TrailheadEntry entry = new TrailheadEntry(uB);
        results.add(entry);
      }
    }

    //-- assign due dates
    Date today = Date.today();
    for (TrailheadEntry entryToInitialize : results) {
      entryToInitialize.calculateDaysUntilDue(today);
    }

    return results;
  }

  /**
   * @description Determines the current set of badges assigned to the current user.
   * @param pageSize (Integer) - the number of records to return
   * @return trailheadapp__User_Badge__c[] - collection of userBadge assignments for the user
   **/
  private static trailheadapp__User_Badge__c[] getAssignedBadges(
    integer pageSize
  ) {
    //workaround for lwc parameter typing bug
    pageSize = Integer.valueOf(pageSize);

    Id userId = UserInfo.getUserId();

    if (trailheadapp__User_Badge__c.SObjectType.getDescribe().isAccessible()) {
      return [
        SELECT
          Id,
          trailheadapp__Badge__c,
          trailheadapp__Badge__r.trailheadapp__Icon__c,
          trailheadapp__Badge__r.Name,
          trailheadapp__URL__c,
          trailheadapp__Due_Date__c,
          trailheadapp__Status__c,
          trailheadapp__Badge_Icon__c
        FROM trailheadapp__User_Badge__c
        WHERE
          trailheadapp__User__c = :userId
          AND trailheadapp__Finished_Date__c = NULL
        ORDER BY trailheadapp__Due_Date__c ASC NULLS LAST
        LIMIT :pageSize
      ];
    } else {
      return new List<trailheadapp__User_Badge__c>();
    }
  }

  /**
   * @description Determines the current set of trailmixes assigned to the current user.
   * @param pageSize (Integer) - the number of records to return
   * @return trailheadapp__User_Trailmix__c[] - collection of Trailmix assignments for the user
   **/
  private static trailheadapp__User_Trailmix__c[] getAssignedTrails(
    integer pageSize
  ) {
    //workaround for lwc parameter typing bug
    pageSize = Integer.valueOf(pageSize);

    Id userId = UserInfo.getUserId();

    if (
      trailheadapp__User_Trailmix__c.SObjectType.getDescribe().isAccessible()
    ) {
      return [
        SELECT
          Id,
          trailheadapp__Due_At__c,
          trailheadapp__Trailmix__r.trailheadapp__URL__c,
          trailheadapp__Trailmix__r.Name,
          trailheadapp__Status__c
        FROM trailheadapp__User_Trailmix__c
        WHERE
          trailheadapp__User__c = :UserId
          AND trailheadapp__Completed_At__c = NULL
        ORDER BY trailheadapp__Due_At__c ASC NULLS LAST
        LIMIT :pageSize
      ];
    } else {
      return new List<trailheadapp__User_Trailmix__c>();
    }
  }
}
