import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_optionLink(driver, root) {
  let _element = root;
  const _locator = _By.css(`a`);
  return _element.findElement(_locator);
}

export default class RecordCreationFormPicklistOption extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    return new ClickableUtamElement(driver, root);
  }

  async __getOptionLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_optionLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getOptionTitle() {
    const _statement0 = await this.__getOptionLink();
    const _result0 = await _statement0.getTitle();
    return _result0;
  }

  async select() {
    const _statement0 = await this.__getOptionLink();
    await _statement0.click();
  }
}
