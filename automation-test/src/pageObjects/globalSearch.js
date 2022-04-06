"use strict";

var core = require("@utam/core");
var _GlobalSearchResultsList = require("./../pageObjects/globalSearchResultsList");
var _Input = require("./../pageObjects/input");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _GlobalSearchResultsList__default = /*#__PURE__*/ _interopDefaultLegacy(
  _GlobalSearchResultsList
);
var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);

async function _utam_get_globalSearchButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-global-header__item--search`);
  return _element.findElement(_locator);
}

async function _utam_get_globalSearchPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div.forceSearchAssistantDialog`);
  return _element.findElement(_locator);
}

async function _utam_get_lightningInput(driver, root) {
  let _element = await _utam_get_globalSearchPanel(driver, root);
  const _locator = core.By.css(`lightning-input`);
  return _element.findElement(_locator);
}

async function _utam_get_searchResultsList(driver, root) {
  let _element = await _utam_get_globalSearchPanel(driver, root);
  const _locator = core.By.css(`search_dialog-instant-results-list`);
  return _element.findElement(_locator);
}

class GlobalSearch extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getGlobalSearchButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_globalSearchButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getGlobalSearchPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_globalSearchPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getLightningInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningInput(driver, root);
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getSearchResultsList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_searchResultsList(driver, root);
    element = new _GlobalSearchResultsList__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async searchAndRedirectToRecord(searchTerm, resultIndex) {
    const _statement0 = await this.getGlobalSearchButton();
    await _statement0.click();
    const _statement1 = await this.getLightningInput();
    await _statement1.setText(searchTerm);
    const _statement2 = await this.__getSearchResultsList();
    const _statement3 = await _statement2.getSearchResultsListItem(resultIndex);
    await _statement3.selectResult();
  }
}

module.exports = GlobalSearch;
