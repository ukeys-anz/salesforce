/**
 * @author Raman Gupta
 * @since  March 2025
 * @group Models
 * @description Lex Type Address Model
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public virtual with sharing class LexTypeAddress extends CalloutModel {
  /**
   * @description A standardized structured address
   * @note (-- api-linter: core::0143::standardized-codes=disabled
   * aip.dev/not-precedent: We need to do this because reasons. --)
   * @url https://github.com/anzx/apis/blob/-/anz/lexapis/lex/type/address.proto#L10-L161
   */
  public virtual with sharing class Address extends CalloutModel {
    /**
     * @description [A12] Primary point.
     * @examples Business, Residential
     */
    @AuraEnabled
    public String addressType { get; set; }

    /**
     * @description Single-line address as a concatenation of address_line_1, address_line_2, address_line_3, locality, state, and post_code.
     * @examples 242 Pitt Street, SYDNEY NSW 2000
     */
    @AuraEnabled
    public String singleLineAddress { get; set; }

    /**
     * @description Building name, maps to concatenation of "building name" and "building name 2" trimmed.
     * @examples Treasury Building North Wing
     */
    @AuraEnabled
    public String buildingName { get; set; }

    /**
     * @description [P41] "Flat / Unit name"
     * @examples Level 60, Unit 95
     */
    @AuraEnabled
    public String unit { get; set; }

    /**
     * @description [P411] "Flat / Unit type"
     * @examples Level, Unit
     */
    @AuraEnabled
    public String unitType { get; set; }

    /**
     * @description [P412] "Flat / Unit number"
     * @examples 60, 95
     */
    @AuraEnabled
    public String unitNumber { get; set; }

    /**
     * @description [P31] "Building level"
     * @examples Level 7
     */
    @AuraEnabled
    public String buildingLevel { get; set; }

    /**
     * @description [P311] "Building level type"
     * @examples Level
     */
    @AuraEnabled
    public String buildingLevelType { get; set; }

    /**
     * @description [P312] "Building level number"
     * @examples 7
     */
    @AuraEnabled
    public String buildingLevelNumber { get; set; }

    /**
     * @description [P11] "Building number"
     * @examples 15, 15b, 1-26
     */
    @AuraEnabled
    public String buildingNumber { get; set; }

    /**
     * @description [B10] "Postal delivery"
     * @examples PO Box 65, GPO Box M929, Private Bag 6060
     */
    @AuraEnabled
    public String postalDelivery { get; set; }

    /**
     * @description [B101] "Postal delivery type"
     * @examples PO Box, GPO Box, Private Bag
     */
    @AuraEnabled
    public String postalDeliveryType { get; set; }

    /**
     * @description [B102] "Postal delivery number"
     * @examples 65, M929, 6060
     */
    @AuraEnabled
    public String postalDeliveryNumber { get; set; }

    /**
     * @description [P13] "Allotment"
     * @examples Lot 60
     */
    @AuraEnabled
    public String allotment { get; set; }

    /**
     * @description [P131] "Allotment lot"
     * @examples Lot
     */
    @AuraEnabled
    public String allotmentType { get; set; }

    /**
     * @description [P132] "Allotment number"
     * @examples 60
     */
    @AuraEnabled
    public String allotmentNumber { get; set; }

    /**
     * @description [S11] "Street"
     * @examples Tudor Court East
     */
    @AuraEnabled
    public String street { get; set; }

    /**
     * @description [S111] "Street name"
     * @examples Tudor
     */
    @AuraEnabled
    public String streetName { get; set; }

    /**
     * @description [S112] "Street type"
     * @examples Court
     */
    @AuraEnabled
    public String streetType { get; set; }

    /**
     * @description [S113] "Street type suffix"
     * @examples East
     */
    @AuraEnabled
    public String streetSuffix { get; set; }

    /**
     * @description [L21] "Locality"
     * @examples Auburn, Chiswick
     */
    @AuraEnabled
    public String locality { get; set; }

    /**
     * @description [L11] "State code"
     * @examples VIC, QLD
     */
    @AuraEnabled
    public String state { get; set; }

    /**
     * @description [C11] "Postal code"
     * @examples 4807
     */
    @AuraEnabled
    public String postalCode { get; set; }

    /**
     * @description [X11] "Country name"
     * @examples Australia
     */
    @AuraEnabled
    public String country { get; set; }

    /**
     * @description [X13] "ISO 3 letter country code"
     * @examples AUS
     */
    @AuraEnabled
    public String countryCode { get; set; }

    /**
     * @description [Latitude] GNAF Latitude.
     * @note A double latitude-valued stringified with the following rules:
     * 1. An optional sign "+" or "-" is allowed.
     * 2. An optional integer part is permissible, without any thousand separators.
     * 3. A fractional part is also optional. If present, it should start with a ".", and it must not include any other separators.
     * 4. The value should always contain at least an integer or a fractional part.
     * 5. The value, including the sign, must fall within the range of -90 to +90, inclusive.
     * @examples -33.87221812
     */
    @AuraEnabled
    public String latitude { get; set; }

    /**
     * @description [Longitude] GNAF Longitude.
     * @note A double longitude-valued stringified with the following rules:
     * 1. An optional sign "+" or "-" is allowed.
     * 2. An optional integer part is permissible, without any thousand separators.
     * 3. A fractional part is also optional. If present, it should start with a ".", and it must not include any other separators.
     * 4. The value should always contain at least an integer or a fractional part.
     * 5. The value, including the sign, must fall within the range of -180 to +180, inclusive.
     * @examples 151.20872622
     */
    @AuraEnabled
    public String longitude { get; set; }

    /**
     * @description [A11] Delivery Point Identifier.
     * @examples 56729927
     */
    @AuraEnabled
    public String deliveryPointId { get; set; }

    /**
     * @description [AUSHIN/Code] HIN.
     * @examples 999592806
     */
    @AuraEnabled
    public String householdIdentificationNumber { get; set; }

    /**
     * @description [AUSBAR] Delivery Point Barcode.
     * @examples 1301012112000122301110300200220302313
     */
    @AuraEnabled
    public String deliveryPointBarcode { get; set; }

    /**
     * @description [AUSBSP] Barcode Element Sort Plan Number.
     * @examples 015
     */
    @AuraEnabled
    public String sortPlanNumber { get; set; }

    /**
     * @description [AUSLGA/Desc] The name of the Local Government Area.
     * @examples Onkaparinga
     */
    @AuraEnabled
    public String council { get; set; }

    /**
     * @description [AUSLGA/Code] Local Government Area Code.
     * @examples 45340
     */
    @AuraEnabled
    public String councilCode { get; set; }

    /**
     * @description [SA1Code] 11-digit SA1 code will be stored in the DB.
     * @note An 11-digit SA1 code consists of: S4433222211. The first 9 digits are SA2.
     * @examples SA1: 11703164428, SA2: 117031644
     */
    @AuraEnabled
    public String sa2Code { get; set; }
  }
}
