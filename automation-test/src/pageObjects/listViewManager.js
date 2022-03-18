"use strict";

var core = require("@utam/core");
var _ListViewManagerHeader = require("./../pageObjects/listViewManagerHeader");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ListViewManagerHeader__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ListViewManagerHeader
);

async function _utam_get_header(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceListViewManagerHeader`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewContainer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.listViewContainer *`);
  return _element.findElement(_locator);
}

class ListViewManager extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_header(driver, root);
    element = new _ListViewManagerHeader__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getListViewContainer(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listViewContainer(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }
}

module.exports = ListViewManager;
