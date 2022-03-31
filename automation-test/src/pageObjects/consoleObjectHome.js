"use strict";

var core = require("@utam/core");
var _ListViewManager = require("./../pageObjects/listViewManager");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ListViewManager__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ListViewManager);

async function _utam_get_listView(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceListViewManager`);
  return _element.findElement(_locator);
}

class ConsoleObjectHome extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`.oneConsoleObjectHome`)) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getListView() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listView(driver, root);
    element = new _ListViewManager__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = ConsoleObjectHome;
