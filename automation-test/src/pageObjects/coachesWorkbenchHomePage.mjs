import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CompletedQARelatedList from "./../pageObjects/completedQARelatedList";
import _HomePageListView from "./../pageObjects/homePageListView";

async function _utam_filter_listViewByTitle(element, title) {
  const result = await element.getListViewTitle();
  return result === title;
}

async function _utam_get_homePage(driver, root) {
  let _element = root;
  const _locator = _By.css(`.active.lafPageHost`);
  return _element.findElement(_locator);
}

async function _utam_get_completedQARelatedList(driver, root) {
  let _element = await _utam_get_homePage(driver, root);
  const _locator = _By.css(`.colSide > .flexipageComponent:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewByTitles(driver, root) {
  let _element = await _utam_get_homePage(driver, root);
  const _locator = _By.css(`.flexipageFilterListCard`);
  return _element.findElements(_locator);
}

export default class CoachesWorkbenchHomePage extends _UtamBaseRootPageObject {
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

  async __getHomePage() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_homePage(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getCompletedQARelatedList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_completedQARelatedList(driver, root);
    element = new _CompletedQARelatedList(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getListViewByTitle(title) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_listViewByTitles(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _HomePageListView(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_listViewByTitle(el, title))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}
