"use strict";

var core = require("@utam/core");
var _HomePageListView = require("./../pageObjects/homePageListView");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _HomePageListView__default =
  /*#__PURE__*/ _interopDefaultLegacy(_HomePageListView);

async function _utam_filter_listViewByTitle(element, title) {
  const result = await element.getListViewTitle();
  return result === title;
}

async function _utam_get_homePage(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.active.lafPageHost`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewByTitles(driver, root) {
  let _element = await _utam_get_homePage(driver, root);
  const _locator = core.By.css(`.flexipageComponent`);
  return _element.findElements(_locator);
}

class QualityWorkbenchHomePage extends core.UtamBaseRootPageObject {
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

  async __getHomePage() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_homePage(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getListViewByTitle(title) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_listViewByTitles(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _HomePageListView__default["default"](driver, element);
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

module.exports = QualityWorkbenchHomePage;
