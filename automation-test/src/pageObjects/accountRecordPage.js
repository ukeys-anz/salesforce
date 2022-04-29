"use strict";

var core = require("@utam/core");
var _LwcPersonAccountFinancialDetails = require("./../pageObjects/lwcPersonAccountFinancialDetails");
var _ChatterPanel = require("./../pageObjects/chatterPanel");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcPersonAccountFinancialDetails__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcPersonAccountFinancialDetails);
var _ChatterPanel__default = /*#__PURE__*/ _interopDefaultLegacy(_ChatterPanel);

async function _utam_get_personAccountFinancialDetails(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.main-col flexipage-component2:nth-of-type(1) c-person-account-financial-details`
  );
  return _element.findElement(_locator);
}

async function _utam_get_chatterWrapper(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.right-col flexipage-component2:nth-of-type(3) flexipage-aura-wrapper`
  );
  return _element.findElement(_locator);
}

async function _utam_get_chatterPanel(driver, root) {
  let _element = await _utam_get_chatterWrapper(driver, root);
  const _locator = core.By.css(`.forceChatterRecordFeedContainerDesktop`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class AccountRecordPage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getPersonAccountFinancialDetails() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_personAccountFinancialDetails(driver, root);
    element = new _LwcPersonAccountFinancialDetails__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async __getChatterWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_chatterWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getChatterPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_chatterPanel(driver, root);
    element = new _ChatterPanel__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = AccountRecordPage;
