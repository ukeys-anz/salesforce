import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ListViewManagerHeader from "./../pageObjects/listViewManagerHeader";

async function _utam_get_header(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceListViewManagerHeader`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewContainer(driver, root) {
  let _element = root;
  const _locator = _By.css(`.listViewContainer *`);
  return _element.findElement(_locator);
}

export default class ListViewManager extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_header(driver, root);
    element = new _ListViewManagerHeader(driver, element);
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
