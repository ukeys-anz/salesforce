import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _ListViewManager from "./../pageObjects/listViewManager";

async function _utam_get_listView(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceListViewManager`);
  return _element.findElement(_locator);
}

export default class ConsoleObjectHome extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`.oneConsoleObjectHome`)) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getListView() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listView(driver, root);
    element = new _ListViewManager(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
