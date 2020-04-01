interface IBase {
  InstanceUrl: string;
  AccessToken: string;
  JSForceConn: any;
}

export class Base implements IBase {
  private _instanceUrl: string = "";
  private _accessToken: string = "";
  private _jsForceConn: any;

  public get InstanceUrl() {
    return this._instanceUrl;
  }

  public get AccessToken() {
    return this._accessToken;
  }

  public get JSForceConn() {
    return this._jsForceConn;
  }

  public setInstanceUrl(url: string) {
    this._instanceUrl = url;
  }

  public setAccessToken(token: string) {
    this._accessToken = token;
  }

  public setJsForceConnection(connection: any) {
    this._jsForceConn = connection;
  }
}
