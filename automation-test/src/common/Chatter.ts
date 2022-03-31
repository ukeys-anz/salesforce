import AccountRecordHomeFlexipage from "pageObjects/coachesWorkbenchAccountRecordHomeFlexipage";
import RootPageModal from "pageObjects/rootPageModal";
import IChatter from "interfaces/IChatter";
import { getCreditCardNumberString } from "utils/commonUtils";

const generalComment = `Automation Test @ ${new Date().toLocaleString()}. `;

export default class Chatter implements IChatter {
  pageType: string;

  constructor(pageType: string) {
    this.pageType = pageType;
  }

  async postChatterComment(commentType: string): Promise<void> {
    const pageRoot = await this.getPageRoot();
    // the getChatterPanel method only exist in Account Record Page
    // new page should also has a getChatterPanel to interact with Chatter Panel
    const chatterPanel = await pageRoot.getChatterPanel();

    switch (commentType) {
      case "CreditCard":
        await chatterPanel.postComment(
          generalComment + "Credit Card Number: " + getCreditCardNumberString()
        );
        break;
      default:
        await chatterPanel.postComment(generalComment);
    }
  }

  async verifyChatterComment(commentType: string): Promise<void> {
    const pageRoot = await this.getPageRoot();
    const chatterPanel = await pageRoot.getChatterPanel();

    switch (commentType) {
      case "CreditCard":
        expect(await chatterPanel.latestPostContentHasMasked()).toEqual(true);
        break;
      default:
        expect(
          await chatterPanel.latestPostContentEquals(generalComment)
        ).toEqual(true);
    }
  }

  async deleteChatterComment(): Promise<void> {
    const pageRoot = await this.getPageRoot();
    const chatterPanel = await pageRoot.getChatterPanel();

    await chatterPanel.clickDeleteLatestPost();

    const confirmModal = await utam.load(RootPageModal);
    expect(await confirmModal.userHasNoPermissionToDeleteChatterPost()).toEqual(
      true
    );
  }

  getPageRoot() {
    switch (this.pageType) {
      case "Account":
        return utam.load(AccountRecordHomeFlexipage);
      default:
        // default return account record page root
        return utam.load(AccountRecordHomeFlexipage);
    }
  }
}
