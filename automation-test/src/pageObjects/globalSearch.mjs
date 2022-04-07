import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";
import _GlobalSearchResultsList from "./../pageObjects/globalSearchResultsList";
import _Input from "./../pageObjects/input";

async function _utam_get_globalSearchButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-global-header__item--search`);
  return _element.findElement(_locator);
}

async function _utam_get_globalSearchPanel(driver, root) {
  let _element = root;
  const _locator = _By.css(`div.forceSearchAssistantDialog`);
  return _element.findElement(_locator);
}

async function _utam_get_lightningInput(driver, root) {
  let _element = await _utam_get_globalSearchPanel(driver, root);
  const _locator = _By.css(`lightning-input`);
  return _element.findElement(_locator);
}

async function _utam_get_searchResultsList(driver, root) {
  let _element = await _utam_get_globalSearchPanel(driver, root);
  const _locator = _By.css(`search_dialog-instant-results-list`);
  return _element.findElement(_locator);
}

export default class GlobalSearch extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
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
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getGlobalSearchButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_globalSearchButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getGlobalSearchPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_globalSearchPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getLightningInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningInput(driver, root);
    element = new _Input(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getSearchResultsList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_searchResultsList(driver, root);
    element = new _GlobalSearchResultsList(driver, element);
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
