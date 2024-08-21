import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import getCardList from "@salesforce/apex/CardDetailsController.getCardList";
import { updateCardFields } from "./helper/helper-mappings";
import { handleErrorShowToast } from "c/utils";
import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";
import { filterCardsBasedOnStatus } from "./helper/helper-cardFilter";

export default class ViewCardsParent extends LightningElement {
  activeCardList = [];
  closedCardList = [];
  loading = false;
  cardHasError = false;
  errorMsg;
  userHasViewPermission = hasViewCardsPermission;
  hasPermissionIssue = this.userHasViewPermission ? false : true;
  noActiveCardMessage = `This customer doesn't have any accounts with an active card attached.`;

  @wire(CurrentPageReference)
  pageRef;

  async connectedCallback() {
    this.ocvId = this.pageRef.state.c__ocvid;
    await this.getListAllCardDetails();
  }

  async getListAllCardDetails() {
    this.loading = true;
    if (this.hasPermissionIssue) {
      this.cardHasError = true;
      this.loading = false;
    }
    try {
      let cardsDetails = await getCardList({ ocvId: this.ocvId });
      if (cardsDetails.cards && cardsDetails.cards.length > 0) {
        let cards = updateCardFields(cardsDetails.cards);
        this.activeCardList = filterCardsBasedOnStatus(cards, true);
        this.closedCardList = filterCardsBasedOnStatus(cards, false);
      }
      this.loading = false;
    } catch (error) {
      this.cardHasError = true;
      this.loading = false;
      this.errorMsg =
        "An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists";
      handleErrorShowToast(
        this,
        "Card List Load Failed",
        this.errorMsg,
        this.errorMsg
      );
    }
  }

  get showNoCardsMessage() {
    return this.noActiveCards && this.noClosedCards;
  }

  get noActiveCards() {
    return this.activeCardList.length === 0;
  }

  get noClosedCards() {
    return this.closedCardList.length === 0;
  }

  refetchCardDetails(event) {
    if (event.detail) {
      this.getListAllCardDetails();
    }
  }
}
