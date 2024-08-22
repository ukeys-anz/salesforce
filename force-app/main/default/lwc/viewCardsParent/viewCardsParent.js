import { LightningElement, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import hasViewCardsPermission from "@salesforce/customPermission/ANZx_View_Cards";
import getCardList from "@salesforce/apex/CardDetailsController.getCardList";
import { handleErrorShowToast } from "c/utils";
import { updateCardFields } from "./helper/helper-mappings";
import { filterCardsBasedOnStatus } from "./helper/helper-cardFilter";

export default class ViewCardsParent extends LightningElement {
  activeCardList = [];
  closedCardList = [];
  loading = false;
  cardHasError = false;
  errorMsg;
  hasPermissionIssue = !hasViewCardsPermission;
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
      return;
    }
    try {
      let cardsDetails = await getCardList({ ocvId: this.ocvId });
      if (cardsDetails?.cards.length > 0) {
        let cards = updateCardFields(cardsDetails.cards);
        this.activeCardList = filterCardsBasedOnStatus(cards, true);
        this.closedCardList = filterCardsBasedOnStatus(cards, false);
      }
    } catch (error) {
      this.cardHasError = true;
      this.errorMsg =
        "An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists";
      handleErrorShowToast(
        this,
        "Card List Load Failed",
        this.errorMsg,
        this.errorMsg
      );
    } finally {
      this.loading = false;
    }
  }

  get showClosedCardsSection() {
    return !this.noClosedCards;
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

  //Refetch the card details in order to get the latest cards list on any button click
  refreshCardDetails(event) {
    if (event.detail) {
      this.getListAllCardDetails();
    }
  }
}
