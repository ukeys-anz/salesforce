import LwcViewCardsDetails from "pageObjects/lwcViewCardsDetails";
import RecordPage from "pageObjects/recordPage";

export default class Card {
  // all cards details
  cards: LwcViewCardsDetails[] | undefined;

  async showDetails(): Promise<void> {
    // load Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();
    const viewCards = await accountRecordPage.getViewCards();
    await viewCards.showDetails();

    this.cards = (await viewCards.getCards())!;
  }

  // only verify the details of the first card
  // can extend to verify all cards details if needed
  async verifyDetails(): Promise<void> {
    const firstCard = this.cards![0];
    expect(await firstCard.isCardHolderVisible()).toBeTruthy();
    expect(await firstCard.isLast4DigitsVisible()).toBeTruthy();
    expect(await firstCard.isExpiryDateVisible()).toBeTruthy();
    expect(await firstCard.isStatusVisible()).toBeTruthy();
  }

  async loadMore(): Promise<void> {
    // load Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();
    const viewCards = await accountRecordPage.getViewCards();

    const isInDetailsView = await viewCards.isInDetailsView();

    if (!isInDetailsView) {
      await viewCards.showDetails();
    }

    const hasMoreCards = await viewCards.hasMoreCards();

    if (hasMoreCards) {
      await viewCards.loadMore();
      this.cards = (await viewCards.getCards())!;
    }
  }

  async verifyFirstCardActive(): Promise<void> {
    const firstCardStatus = await this.cards![0].getStatus();
    expect(firstCardStatus).toEqual("Issued");
  }
}
