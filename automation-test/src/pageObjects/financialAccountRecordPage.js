"use strict";

var core = require("@utam/core");
var _Tabset2 = require("./../pageObjects/tabset2");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Tabset2__default = /*#__PURE__*/ _interopDefaultLegacy(_Tabset2);

async function _utam_get_accountTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.region-main flexipage-component2:nth-of-type(1) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

class FinancialAccountRecordPage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getAccountTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_accountTabset(driver, root);
    element = new _Tabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = FinancialAccountRecordPage;
