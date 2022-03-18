import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _GlobalSearchResultsListItem from "./../pageObjects/globalSearchResultsListItem";

async function _utam_get_searchResultsListItem(driver, root, resultIndex) {
  let _element = root;
  const _locator = _By.css(
    `search_dialog-instant-result-item:nth-of-type(${resultIndex})`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class GlobalSearchResultsList extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getSearchResultsListItem(resultIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_searchResultsListItem(
      driver,
      root,
      resultIndex
    );
    element = new _GlobalSearchResultsListItem(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
