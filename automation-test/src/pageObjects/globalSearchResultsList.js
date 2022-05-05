"use strict";

var core = require("@utam/core");
var _GlobalSearchResultsListItem = require("./../pageObjects/globalSearchResultsListItem");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _GlobalSearchResultsListItem__default = /*#__PURE__*/ _interopDefaultLegacy(
  _GlobalSearchResultsListItem
);

async function _utam_get_searchResultsListItem(driver, root) {
  let _element = root;
  const _locator = core.By.css(`search_dialog-instant-result-item`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class GlobalSearchResultsList extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getSearchResultsListItem() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_searchResultsListItem(driver, root);
    element = new _GlobalSearchResultsListItem__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async selectFirstResult() {
    const _statement0 = await this.__getSearchResultsListItem();
    await _statement0.selectResult();
  }
}

module.exports = GlobalSearchResultsList;
