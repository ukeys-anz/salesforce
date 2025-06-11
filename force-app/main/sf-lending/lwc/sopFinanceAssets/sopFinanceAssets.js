import { LightningElement, api } from "lwc";
import ERROR_IMG from "@salesforce/resourceUrl/No_savings_img";
import PROPERTY_IMG from "@salesforce/resourceUrl/Property";
import INVESTMENT_IMG from "@salesforce/resourceUrl/Investment";
import SUPER_IMG from "@salesforce/resourceUrl/Super";
import VEHICLE_IMG from "@salesforce/resourceUrl/Vehicle";
import CONTENTS_IMG from "@salesforce/resourceUrl/Content";
import OTHER_ASSET_IMG from "@salesforce/resourceUrl/Other_Asset";

const TYPE_MAP = {
  ASSET_TYPE_PROPERTY: "Property",
  ASSET_TYPE_SHARES: "Investment",
  ASSET_TYPE_SUPER: "Super",
  ASSET_TYPE_VEHICLE: "Vehicle",
  ASSET_TYPE_HOME_CONTENTS: "Contents",
  ASSET_TYPE_OTHER: "Other"
};

const SOURCE_MAP = {
  ASSET_SOURCE_ANZ: "ANZ",
  ASSET_SOURCE_MANUAL: "Manual",
  ASSET_SOURCE_BUREAU: "Bureau"
};

const PROPERTY_CAT_MAP = {
  PROPERTY_CATEGORY_UNSPECIFIED: "Unspecified",
  PROPERTY_CATEGORY_RESIDENTIAL: "Residential",
  PROPERTY_CATEGORY_COMMERCIAL: "Commercial"
};

export default class SopFinanceAssets extends LightningElement {
  @api sopAssetsData;
  noDataAvailable = false;
  error_img = ERROR_IMG;
  assets = [
    {
      title: "Property",
      assets: []
    },
    {
      title: "Investment",
      assets: []
    },
    {
      title: "Super",
      assets: []
    },
    {
      title: "Vehicle",
      assets: []
    },
    {
      title: "Contents",
      assets: []
    },
    {
      title: "Other",
      assets: []
    }
  ];
  assetsData;

  connectedCallback() {
    //Check if data is not null
    if (this.sopAssetsData?.assets && this.sopAssetsData?.assets.length > 0) {
      //Need to clone data since cache is read only
      this.assetsData = JSON.parse(JSON.stringify(this.sopAssetsData));

      this.assetsData.assets.sort((a, b) => {
        //Sort by estimatedValue ascending if theres estimatedValue
        if (b.estimatedValue && a.estimatedValue) {
          return b.estimatedValue - a.estimatedValue;
        }
        //Sort by propertyValue ascending if theres propertyValue
        return b.propertyValue - a.propertyValue;
      });

      //Loop through assets data and sort into the assets sections
      this.assetsData.assets.forEach((asset) => {
        asset.source = SOURCE_MAP[asset.source];
        asset.propertyCategory = PROPERTY_CAT_MAP[asset.propertyCategory];
        asset.ownership = asset.belongsTo;
        asset.ownershipSplit = asset.ownershipSplit;

        asset.readableType = TYPE_MAP[asset.type];
        asset.lastModified = this.setTimestamp(asset.updateTime);
        if (this.isPropertyAssetItem(asset)) {
          let property = this.assets.find(
            (assetData) => assetData.title === "Property"
          );
          this.handleFieldConditions("Property", asset);
          if (asset.collateralAssessmentId) {
            property.assets.unshift(asset);
          } else {
            property.assets.push(asset);
          }
        } else if (this.isInvestmentAssetItem(asset)) {
          let investment = this.assets.find(
            (assetData) => assetData.title === "Investment"
          );
          this.handleFieldConditions("Investment", asset);
          investment.assets.push(asset);
        } else if (this.isSuperAssetItem(asset)) {
          let superData = this.assets.find(
            (assetData) => assetData.title === "Super"
          );
          this.handleFieldConditions("Super", asset);
          superData.assets.push(asset);
        } else if (this.isVehicleAssetItem(asset)) {
          let vehicle = this.assets.find(
            (assetData) => assetData.title === "Vehicle"
          );
          this.handleFieldConditions("Vehicle", asset);
          vehicle.assets.push(asset);
        } else if (this.isContentsAssetItem(asset)) {
          let contents = this.assets.find(
            (assetData) => assetData.title === "Contents"
          );
          this.handleFieldConditions("Contents", asset);
          contents.assets.push(asset);
        } else if (this.isOtherAssetItem(asset)) {
          let other = this.assets.find(
            (assetData) => assetData.title === "Other"
          );
          this.handleFieldConditions("Other", asset);
          other.assets.push(asset);
        }
      });

      //Remove any section that doesnt have any assets so we dont loop through
      this.assets = this.assets.filter((el) => el.assets.length > 0);
    } else {
      this.noDataAvailable = true;
    }
  }

  //Check if asset is Property
  isPropertyAssetItem(asset) {
    return asset.type === "ASSET_TYPE_PROPERTY";
  }

  //Check if asset is Investment
  isInvestmentAssetItem(asset) {
    return asset.type === "ASSET_TYPE_SHARES";
  }

  //Check if asset is Super
  isSuperAssetItem(asset) {
    return asset.type === "ASSET_TYPE_SUPER";
  }

  //Check if asset is Vehicle
  isVehicleAssetItem(asset) {
    return asset.type === "ASSET_TYPE_VEHICLE";
  }

  //Check if asset is Contents
  isContentsAssetItem(asset) {
    return asset.type === "ASSET_TYPE_HOME_CONTENTS";
  }

  //Check if asset is Other
  isOtherAssetItem(asset) {
    return asset.type === "ASSET_TYPE_OTHER";
  }

  //Used to determine visibility of fields
  handleFieldConditions(type, asset) {
    switch (type) {
      case "Property":
        if (asset.collateralAssessmentId) {
          asset.showPropertyValuation = true;
        } else {
          asset.showANZEstimate = true;
          asset.showCustomerEstimate = true;
          asset.showPropertyValuation = false;
        }
        asset.showPropertyType = true;
        asset.showAddress = true;
        asset.showName = false;
        asset.showValue = false;
        asset.showVehicleType = false;
        asset.showSource = true;
        asset.image = PROPERTY_IMG;
        break;
      case "Investment":
        asset.showAddress = false;
        asset.showPropertyValuation = false;
        asset.showName = true;
        asset.showValue = true;
        asset.showVehicleType = false;
        asset.showSource = false;
        asset.image = INVESTMENT_IMG;
        break;
      case "Super":
        asset.showAddress = false;
        asset.showPropertyValuation = false;
        asset.showName = true;
        asset.showValue = true;
        asset.showVehicleType = false;
        asset.showSource = false;
        asset.image = SUPER_IMG;
        break;
      case "Vehicle":
        asset.showAddress = false;
        asset.showPropertyValuation = false;
        asset.showName = true;
        asset.showValue = true;
        asset.showVehicleType = true;
        asset.showSource = false;
        asset.image = VEHICLE_IMG;
        break;
      case "Contents":
        asset.showAddress = false;
        asset.showPropertyValuation = false;
        asset.showName = false;
        asset.showValue = true;
        asset.showVehicleType = false;
        asset.showSource = false;
        asset.image = CONTENTS_IMG;
        break;
      case "Other":
        asset.showAddress = false;
        asset.showPropertyValuation = false;
        asset.showName = true;
        asset.showValue = true;
        asset.showVehicleType = false;
        asset.showSource = false;
        asset.image = OTHER_ASSET_IMG;
        break;
      default:
        break;
    }
  }

  setTimestamp(timestamp) {
    //Create timestamp for last updated
    let lastModified = new Date(timestamp);
    lastModified =
      lastModified.getDate() +
      " " +
      lastModified.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      lastModified.getFullYear() +
      " | " +
      lastModified.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
    return lastModified;
  }
}
