import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_content(driver, root) {
  let _element = root;
  const _locator = _By.css(`:scope > *:first-child`);
  return _element.findElement(_locator);
}

async function _utam_get_contentInsideSlot(driver, root) {
  let _element = root;
  const _locator = _By.css(`:not(slot)`);
  return _element.findElement(_locator);
}

async function _utam_get_generatedTemplate(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forcegenerated-flexipage-template`);
  return _element.findElement(_locator);
}

export default class RecordLayoutEventBroker extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_content(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getContentInsideSlot(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_contentInsideSlot(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getGeneratedTemplate(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_generatedTemplate(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async waitForTemplate() {
    await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`.forcegenerated-flexipage-template`)
      );
      return _result0;
    });
    return this;
  }
}
