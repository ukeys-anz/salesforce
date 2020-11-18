/** Jest test for the th_trailheadAssignment_entry component */
import { createElement } from "lwc";
import trailheadAssignmentEntry from "c/th_trailheadAssignment_entry";

const DUE_OVERDUE = {
  dueDate: "2019-03-22T19:00:00.000Z",
  entryType: "Badge",
  icon:
    "https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/modules/lightning-web-components-basics/80a88b1ee88352b7377f12382b3cff17_badge.png",
  id: "a062E00001O0dEKQAZ",
  name: "Lightning Web Components Basics",
  numDaysUntilDue: -11,
  status: "Assigned",
  url:
    "https://developer.salesforce.com/trailhead/module/lightning-web-components-basics/"
};
const DUE_TODAY = {
  dueDate: "2019-04-02T19:00:00.000Z",
  entryType: "Badge",
  icon:
    "https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/projects/set-up-your-lightning-web-components-developer-tools/c3dcf42d860258cf365b5f4ff17bea7d_badge.png",
  id: "a062E00001O0dEBQAZ",
  name: "Set Up Your Lightning Web Components Developer Tools",
  numDaysUntilDue: 0,
  status: "Assigned",
  url:
    "https://developer.salesforce.com/trailhead/project/set-up-your-lightning-web-components-developer-tools/"
};
const DUE_TOMORROW = {
  dueDate: "2019-04-03T19:00:00.000Z",
  entryType: "TrailMix",
  icon:
    "https://trailhead-web.s3.amazonaws.com/uploads/users/5396019/photos/thumb_030804d3576dab0cdc2a558055816208e421312a9d1495117d57928ef380d7f2.png?updatedAt=20180906113753",
  id: "a072E00000XdoY0QAJ",
  name: "Architect Journey: Integration Architecture",
  numDaysUntilDue: 1,
  url:
    "https://developer.salesforce.com/trailhead/users/strailhead/trailmixes/architect-integration-architecture"
};
const DUE_LATER = {
  dueDate: "2019-04-22T19:00:00.000Z",
  entryType: "Badge",
  icon:
    "https://res.cloudinary.com/hy4kyit2a/f_auto,fl_lossy,q_70/learn/projects/quick-start-lightning-web-components/a5b473dc9b5fec5a2aef823b218a35bf_badge.png",
  id: "a062E00001O0dEQQAZ",
  name: "Quick Start: Lightning Web Components",
  numDaysUntilDue: 20,
  status: "Assigned",
  url:
    "https://developer.salesforce.com/trailhead/project/quick-start-lightning-web-components/"
};

describe("c-th_trailheadAssignment_entry", () => {
  //-- boilerplate DOM reset
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  describe("initializes correctly", () => {
    it("when no assignment entry is provided", () => {
      const element = createElement("th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      document.body.appendChild(element);
      expect(element).not.toBeNull();

      expect(element.assignmentEntry).not.toBe(null);
      expect(element.hasDueDate).toBe(false);
    });

    it("when an assignment is provided", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_OVERDUE;
      document.body.appendChild(element);

      expect(element.assignmentEntry).not.toBe(null);
      expect(element.assignmentEntry.entryType).toBe("Badge");
    });

    it("has a due date when provided", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_OVERDUE;
      element.upcomingEventWindow = 7;
      expect(element.hasDueDate).toBe(true);
    });

    it("has overdue status if the assignment is overdue", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_OVERDUE;
      element.upcomingEventWindow = 7;
      expect(element.statusClass).toContain("event-due");
    });
    it("has Due status if the assignment is due today", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_TODAY;
      element.upcomingEventWindow = 7;
      expect(element.statusClass).toContain("event-upcoming");
    });
    it("has upcoming status if the assignment is due tomorrow", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_TOMORROW;
      element.upcomingEventWindow = 7;
      expect(element.statusClass).toContain("event-upcoming");
    });
    it("has upcoming status if the assignment is due later", () => {
      const element = createElement("c-th_trailhead-assignment_entry", {
        is: trailheadAssignmentEntry
      });
      element.assignmentEntry = DUE_LATER;
      element.upcomingEventWindow = 7;
      expect(element.statusClass).toContain("event-standard");
    });
  });
});
