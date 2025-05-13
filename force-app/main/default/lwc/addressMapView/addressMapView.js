import { api, LightningElement } from "lwc";

export default class AddressMapView extends LightningElement {
  @api zoomLevel = 15;
  @api addressDetails;

  get mapMarkers() {
    if (!this.addressDetails) {
      return null;
    }
    return [
      {
        location: {
          Latitude: this.addressDetails.latitude,
          Longitude: this.addressDetails.longitude
        }
      }
    ];
  }

  get showMap() {
    return (
      this.addressDetails &&
      this.addressDetails.latitude &&
      this.addressDetails.longitude
    );
  }
}
