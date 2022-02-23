"use strict";

var core = require("@utam/core");

async function _utam_get_newCase(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a div[title='New']`);
  return _element.findElement(_locator);
}

async function _utam_get_selectElementss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div a[class='select']`);
  return _element.findElements(_locator);
}

async function _utam_get_generalEnquiryChk(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[name='General_Inquiry']`);
  return _element.findElement(_locator);
}

async function _utam_get_anzxComplaint(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[name='ANZx_Complaint']`);
  return _element.findElement(_locator);
}

async function _utam_get_nextButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`footer button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_channelReceived(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a[class='select']:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_tabItem(driver, root, index) {
  let _element = root;
  const _locator = core.By.css(
    `li[class='tabItem'] button:nth-of-type(${index})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_customerDropDown(driver, root, customerName) {
  let _element = root;
  const _locator = core.By.css(`li div[title='${customerName}']`);
  return _element.findElement(_locator);
}

async function _utam_get_valueDropDown(driver, root, itemValue) {
  let _element = root;
  const _locator = core.By.css(`li a[title='${itemValue}']`);
  return _element.findElement(_locator);
}

async function _utam_get_dualListLeft(driver, root, itemValue) {
  let _element = root;
  const _locator = core.By.css(`div span[title='${itemValue}']`);
  return _element.findElement(_locator);
}

async function _utam_get_dualListLeftItemss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`li[lightning-duallistbox_duallistbox]`);
  return _element.findElements(_locator);
}

async function _utam_get_moveChosen(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Move selection to Chosen']`);
  return _element.findElement(_locator);
}

async function _utam_get_saveCase(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Save']`);
  return _element.findElement(_locator);
}

async function _utam_get_customerInput(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[title='Search Accounts']`);
  return _element.findElement(_locator);
}

class LwcCaseCreation extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getNewCase() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_newCase(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSelectElements() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_selectElementss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async getGeneralEnquiryChk() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_generalEnquiryChk(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAnzxComplaint() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_anzxComplaint(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getNextButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_nextButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getChannelReceived() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_channelReceived(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getTabItem(index) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_tabItem(driver, root, index);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getCustomerDropDown(customerName) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_customerDropDown(driver, root, customerName);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getValueDropDown(itemValue) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_valueDropDown(driver, root, itemValue);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getDualListLeft(itemValue) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_dualListLeft(driver, root, itemValue);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getDualListLeftItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_dualListLeftItemss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async getMoveChosen() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_moveChosen(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSaveCase() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveCase(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getCustomerInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_customerInput(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }
}

module.exports = LwcCaseCreation;
