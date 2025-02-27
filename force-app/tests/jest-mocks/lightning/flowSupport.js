export const FlowNavigationNextEventName = "lightning__flownextevent";

export class FlowNavigationNextEvent extends CustomEvent {
  constructor(attributeName, attributeValue) {
    super(FlowNavigationNextEventName, {
      composed: true,
      cancelable: true,
      bubbles: true,
      detail: {
        attributeName,
        attributeValue
      }
    });
  }
}
