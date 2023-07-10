/**
 * @author Mani
 * @since June 2023
 * @description This Class provides Fabric specific type models
 */
@SuppressWarnings(
  'PMD.FieldNamingConventions,PMD.FormalParameterNamingConventions'
)
public with sharing class FabricType {
  /**
   * @description Represents a money/ currency in fabric type format https://github.com/anzx/apis/blob/main/anz/fabricapis/fabric/type/money.proto
   */
  public class FabricMoney extends Money {
    @AuraEnabled
    public String currencyCode;
    /**
     * @description Constructor to set the fabric money
     * @param currencyCode The 3-letter currency code defined in ISO 4217. example AUD
     * @param units The whole units of the amount. For example if `currency_code` is `"AUD"`, then 1 unit is one Australian dollar.
     * @param nanos Number of nano (10^-9) units of the amount.
     */
    public FabricMoney(String currencyCode, String units, Integer nanos) {
      super(units, nanos);
      this.currencyCode = currencyCode;
    }
    /**
     * @description Constructor to set the fabric money
     * @param currencyCode The 3-letter currency code defined in ISO 4217. example AUD
     * @param amount The whole value of the amount stored in salesforce as Decimal. For example if `currency_code` is `"AUD"`, then 456.50 Australian dollar.
     */
    public FabricMoney(String currencyCode, Decimal amount) {
      super(amount);
      this.currencyCode = currencyCode;
    }
  }

  /**
   * @description Represents a money/ currency in fabric type format https://github.com/anzx/apis/blob/main/anz/fabricapis/fabric/type/money.proto
   */
  public class Fabric_money extends Money {
    @AuraEnabled
    public String currency_code;
    /**
     * @description Constructor to set the fabric money
     * @param currency_code The 3-letter currency code defined in ISO 4217. example AUD
     * @param units The whole units of the amount. For example if `currency_code` is `"AUD"`, then 1 unit is one Australian dollar.
     * @param nanos Number of nano (10^-9) units of the amount.
     */
    public Fabric_money(String currency_code, String units, Integer nanos) {
      super(units, nanos);
      this.currency_code = currency_code;
    }
    /**
     * @description Constructor to set the fabric money
     * @param currency_code The 3-letter currency code defined in ISO 4217. example AUD
     * @param amount The whole value of the amount stored in salesforce as Decimal. For example if `currency_code` is `"AUD"`, then 456.50 Australian dollar.
     */
    public Fabric_money(String currency_code, Decimal amount) {
      super(amount);
      this.currency_code = currency_code;
    }
  }

  /**
   * @description Represents a base class for money/ currency in fabric type format https://github.com/anzx/apis/blob/main/anz/fabricapis/fabric/type/money.proto
   */
  public virtual class Money {
    @AuraEnabled
    public String units;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description Constructor to set the fabric money
     * @param units The whole units of the amount. For example if `currency_code` is `"AUD"`, then 1 unit is one Australian dollar.
     * @param nanos Number of nano (10^-9) units of the amount.
     */
    public Money(String units, Integer nanos) {
      this.units = units;
      this.nanos = nanos;
    }
    /**
     * @description Constructor to set the fabric money
     * @param amount The whole value of the amount stored in salesforce as Decimal. For example if `currency_code` is `"AUD"`, then 456.50 Australian dollar.
     */
    public Money(Decimal amount) {
      if (amount != null) {
        Decimal unitValue = amount.round(System.RoundingMode.DOWN);
        Decimal nanoValue = (amount - unitValue) * 1000000000;
        this.units = String.valueOf(unitValue);
        this.nanos = (Integer) nanoValue.round(System.RoundingMode.DOWN);
      }
    }
    /**
     * @description calculate the value of the amount charged from units and nanos
     * @return `Decimal` amount value store in salesforce format
     */
    public Decimal value() {
      //Need to check if units and nanos exist as they aren't always returned
      if (String.isBlank(this.units) && this.nanos == null) {
        return null;
      }
      Decimal unitValue = String.isNotBlank(this.units)
        ? decimal.valueOf(this.units)
        : 0;
      Decimal nanoValue = this.nanos != null ? this.nanos : 0;
      return unitValue + (nanoValue / 1000000000);
    }
  }

  /**
   * @description Represents a whole or partial calendar date, such as a birthday, in fabric type format
   * https://github.com/anzx/apis/blob/main/anz/fabricapis/fabric/type/date.proto
   */
  public class FabricDate {
    @AuraEnabled
    public FabricOptionalInt year;
    @AuraEnabled
    public FabricOptionalInt month;
    @AuraEnabled
    public FabricOptionalInt day;
    /**
     * @description Constructor to set the fabric Date
     * @param year Year of the date. Must be from 1 to 9999.
     * @param month Month of a year. Must be from 1 to 12,
     * @param day Day of a month. Must be from 1 to 31 and valid for the year and month
     */
    public FabricDate(Integer year, Integer month, Integer day) {
      this.year = new FabricOptionalInt(year);
      this.month = new FabricOptionalInt(month);
      this.day = new FabricOptionalInt(day);
    }
    /**
     * @description Constructor to set the fabric Date
     * @param dateVal Date format as stored in salesforce.
     */
    public FabricDate(Date dateVal) {
      if (dateVal != null) {
        this.year = new FabricOptionalInt(dateVal.year());
        this.month = new FabricOptionalInt(dateVal.month());
        this.day = new FabricOptionalInt(dateVal.day());
      }
    }
    /**
     * @description converts Fabric Date into Salesforce Date value
     * @return `Date` format as stored in salesforce.
     */
    public Date value() {
      if (this.year != null && this.month != null && this.day != null) {
        return date.newInstance(
          this.year.value,
          this.month.value,
          this.day.value
        );
      } else {
        return null;
      }
    }
  }

  /**
   * @description Represents a optional Integer from fabric optional
   * https://github.com/anzx/apis/blob/main/anz/fabricapis/fabric/type/optional.proto#L38
   */
  public class FabricOptionalInt {
    @AuraEnabled
    public Integer value;
    /**
     * @description Constructor to set the fabric Optional Int
     * @param value accepts integer.
     */
    public FabricOptionalInt(Integer value) {
      this.value = value;
    }
  }

  /**
   * @description Represents a whole or partial calendar date including timne, in google type format
   * https://github.com/protocolbuffers/protobuf/blob/main/src/google/protobuf/timestamp.proto
   */
  public class Timestamp {
    @AuraEnabled
    public Long seconds;
    @AuraEnabled
    public Long nanos;
    /**
     * @description Constructor to set the Google Timestamp
     * @param seconds Represents seconds of UTC time since Unix epoch
     * @param nanos Non-negative fractions of a second at nanosecond resolution. Negative second values with fractions must still have non-negative nanos values that count forward in time
     */
    public Timestamp(Long seconds, Long nanos) {
      this.seconds = seconds;
      this.nanos = nanos;
    }
    /**
     * @description Constructor to set the Google Timestamp
     * @param dateTimeval `DateTime` format as stored in salesforce.
     */
    public Timestamp(DateTime dateTimeval) {
      if (dateTimeval != null) {
        long millis = dateTimeval.getTime();
        this.seconds = (millis / 1000);
        this.nanos = math.mod(millis, 1000) * 1000000;
      }
    }
    /**
     * @description Converts Google Timestamp into Salesforce DateTime value
     * @return DateTime format as stored in salesforce.
     */
    public DateTime value() {
      if (this.seconds != null && this.nanos != null) {
        Long secondsValue = (this.seconds * 1000);
        Long nanoValue = (this.nanos / 1000000);
        Long mills = secondsValue + nanoValue;
        return DateTime.newInstance(mills);
      }
      return null;
    }
  }
}
