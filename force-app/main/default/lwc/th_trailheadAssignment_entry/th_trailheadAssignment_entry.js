/**
 * Represents an entry in the list of trailhead assignments.
 */

import { LightningElement, api } from "lwc";

//-- note: custom labels are currently supported in LWC - Custom Settings require an apex callout
//-- because this is an organization wide value, the choice was made to use custom labels instead

/** The default address to show for a trail */
import TRAILHEAD_TRAIL_ICON from "@salesforce/label/c.th_trailhead_trail_icon";

/** The TrailMix entry type */
import ENTRY_TYPE_TRAILMIX from "@salesforce/label/c.th_TrailheadTypeTrailmix";

/** The standard event status */
const STATUS_STANDARD = "event-standard";
/** The event is now due */
const STATUS_DUE = "event-due";
/** The event is considered 'upcoming' */
const STATUS_UPCOMING = "event-upcoming";

export default class Th_trailheadAssignment_entry extends LightningElement {
  /**
   * the assignment
   * @type {AssignmentEntry}
   **/
  @api assignmentEntry = {};

  /**
   * Number of Days until an event is no longer considered 'upcoming'
   * @type {Number}
   **/
  @api upcomingEventWindow;

  //-- internal methods
  /**
   * Whether an assignmentEntry is already assigned to the current person.
   * @param assignmentEntry - AssignmentEntry - The assignment entry given for the current person
   * @return boolean - whether the assignment is currently assigned to the current user (true) or not (false)
   */
  static isCurrentlyAssigned(assignmentEntry) {
    //-- there are three statuses: Assigned, In Progress and Completed
    //-- assume if there is any of those statuses, then it is assigned.
    if (!assignmentEntry) {
      return false;
    }
    let status = assignmentEntry.status;
    let result = false;
    if (status) {
      result = true;
    }
    return result;
  }

  //-- getter / setters

  /**
   * Url for the icon to show
   * @type {string}
   */
  @api
  get iconURL() {
    let result = this.assignmentEntry.icon;
    if (!result || this.assignmentEntry.entryType === ENTRY_TYPE_TRAILMIX) {
      result = TRAILHEAD_TRAIL_ICON;
    }
    return result;
  }

  /**
   * Whether there is a due date assigned
   * @type {boolean}
   */
  @api
  get hasDueDate() {
    //-- move truthy evaluation here for clarity
    return this.assignmentEntry.dueDate ? true : false;
  }

  /**
   * CSS class of the status (based on whether it is overdue, upcoming or in the future)
   * @type {string}
   */
  @api
  get statusClass() {
    let result = "slds-p-left_xxx-small ";

    let daysUntilDue = this.assignmentEntry.numDaysUntilDue;
    if (daysUntilDue < 0) {
      result += STATUS_DUE;
    } else if (daysUntilDue < this.upcomingEventWindow) {
      result += STATUS_UPCOMING;
    } else {
      result += STATUS_STANDARD;
    }

    return result;
  }
}
