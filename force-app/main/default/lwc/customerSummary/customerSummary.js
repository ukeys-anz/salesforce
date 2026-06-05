import { LightningElement, api, wire } from "lwc";
import generateKeyDisscussionPoints from "@salesforce/apex/CustomerSummaryController.generateKeyDisscussionPoints";
import generateAccountSnapshotAndDiaryComments from "@salesforce/apex/CustomerSummaryController.generateAccountSnapshotAndDiaryComments";
import generateOpportunitiesAndLeads from "@salesforce/apex/CustomerSummaryController.generateOpportunitiesAndLeads";
import generateOtherAndTasks from "@salesforce/apex/CustomerSummaryController.generateOtherAndTasks";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { open, execute } from "lightning/accApi";
import getBotId from "@salesforce/apex/CustomerSummaryController.getBotId";

export default class CustomerSummary extends LightningElement {
  @api recordId;
  botId;
  disabledAskAgentforce = false;

  summary;
  isLoading = false;

  @wire(getBotId)
  wiredBot({ error, data }) {
    if (data) {
      this.botId = data;
      console.log("Bot Id:", this.botId);
    } else if (error) {
      console.error("Error fetching Bot Id:", error);
    }
  }

  handleGenerateAll() {
    this.isLoading = true;
    this.disabledAskAgentforce = false;
    this.summary = null;

    Promise.all([
      generateKeyDisscussionPoints({ accountId: this.recordId }),
      generateAccountSnapshotAndDiaryComments({ accountId: this.recordId }),
      generateOpportunitiesAndLeads({ accountId: this.recordId }),
      generateOtherAndTasks({ accountId: this.recordId })
    ])
      .then((results) => {
        // results are returned in the SAME order as Promise.all
        const [keyDiscussion, accountSnapshot, opportunities, otherAndTasks] =
          results;

        this.summary = `
                ${keyDiscussion}
                ${accountSnapshot}
                ${opportunities}
                ${otherAndTasks}
            `;
      })
      .catch((error) => {
        // eslint-disable-next-line no-console
        console.error(error);
        this.summary = "<p><b>Error generating customer summary.</b></p>";
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  showRefreshTooltip = false;

  showTooltip() {
    this.showRefreshTooltip = true;
  }

  hideTooltip() {
    this.showRefreshTooltip = false;
  }

  async handleCopy() {
    if (!this.summary) return;

    try {
      const htmlBlob = new Blob([this.summary], { type: "text/html" });

      const clipboardItem = new ClipboardItem({
        "text/html": htmlBlob
      });

      await navigator.clipboard.write([clipboardItem]);

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Summary was copied",
          message: "",
          variant: "success"
        })
      );
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: error,
          message: "Unable to copy",
          variant: "error"
        })
      );
    }
  }

  async handleAgentLaunch() {
    this.disabledAskAgentforce = true;
    await open(this.botId);
    const contextualUtterance = `Continue from the preceding conversation : \n\n${this.buildAgentContext()}`;
    await execute(contextualUtterance, this.botId);
  }

  buildAgentContext() {
    if (!this.summary) {
      return "";
    }

    const parser = new DOMParser();
    const doc = parser.parseFromString(this.summary, "text/html");

    let context = "";

    // =====================================================
    // POTENTIAL OPPORTUNITIES
    // =====================================================

    context +=
      "Here are the potential opportunities identified from the preceding conversation:\n\n";

    const opportunitiesHeader = Array.from(doc.querySelectorAll("b")).find(
      (el) =>
        el.textContent.trim() === "Insights from Banker Notes and A-Z Reviews"
    );

    if (opportunitiesHeader) {
      const opportunitiesList =
        opportunitiesHeader.closest("div")?.nextElementSibling // disclaimer div
          ?.nextElementSibling; // UL

      if (opportunitiesList && opportunitiesList.tagName === "UL") {
        let counter = 1;

        opportunitiesList.querySelectorAll(":scope > li").forEach((li) => {
          const title = li.querySelector("a b")?.textContent?.trim();

          if (!title) {
            return;
          }

          let description = li.textContent
            .replace(title, "")
            .replace(/^\s*[-–]\s*/, "")
            .replace(/\s+/g, " ")
            .trim();

          context += `${counter}. ${title}\n`;
          context += `Description: ${description}\n\n`;

          counter++;
        });
      }
    }

    // =====================================================
    // SUGGESTED TASKS
    // =====================================================

    context +=
      "\nHere are the suggested tasks from the preceding conversation:\n\n";

    const noTaskMessage =
      "No Interactions or A-Z Reviews have been recorded in the past six months that would indicate any suggested tasks!";

    // ✅ Check if the message exists
    if (doc.body.textContent.includes(noTaskMessage)) {
      context += noTaskMessage + "\n\n";
    } else {
      const tasksHeader = Array.from(doc.querySelectorAll("b")).find(
        (el) =>
          el.textContent.trim() ===
          "Suggested Tasks from Banker Notes/Interactions"
      );

      if (tasksHeader) {
        const taskList = tasksHeader.closest("div")?.querySelector("ol");

        if (taskList) {
          let counter = 1;

          taskList.querySelectorAll(":scope > li").forEach((li) => {
            const title = li.querySelector("a b")?.textContent?.trim();

            if (!title) {
              return;
            }

            let description = li.textContent
              .replace(title, "")
              .replace(/^\s*[-–]\s*/, "")
              .replace(/\s+/g, " ")
              .trim();

            context += `${counter}. ${title}\n`;
            context += `Description: ${description}\n`;
            context += `Priority: Normal\n\n`;

            counter++;
          });
        }
      }
    }

    return context;
  }
}
