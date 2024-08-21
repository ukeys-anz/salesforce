import { LightningElement, api } from "lwc";

export default class CardControl extends LightningElement {
  @api card;
  cardControlFields;

  connectedCallback() {
    this.cardControlFields = this.card.controls.map((record) => {
      return {
        ...record,
        cardControlFieldValue:
          record.value === true || record.value === false ? true : false
      };
    });
  }
}
