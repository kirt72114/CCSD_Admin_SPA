import { Version } from '@microsoft/sp-core-library';
import {
  type IPropertyPaneConfiguration,
  PropertyPaneTextField,
  PropertyPaneDropdown
} from '@microsoft/sp-property-pane';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';
import { SPHttpClient } from '@microsoft/sp-http';

export interface IScriptEditorWebPartProps {
  scriptUrl: string;
  iframeHeight: string;
}

export default class ScriptEditorWebPart extends BaseClientSideWebPart<IScriptEditorWebPartProps> {

  public render(): void {
    this.domElement.innerHTML = '';

    if (this.displayMode === 1) {
      // Edit mode
      this._renderEditPlaceholder();
    } else {
      // Read mode
      this._renderContent();
    }
  }

  private _renderEditPlaceholder(): void {
    const scriptUrl = this.properties.scriptUrl;

    if (scriptUrl) {
      this.domElement.innerHTML = `
        <div style="padding:16px 24px;background:#0078d4;color:#fff;font-family:Segoe UI,sans-serif;border-radius:4px">
          <div style="font-size:16px;font-weight:600;margin-bottom:4px">CCSD Script Editor</div>
          <div style="font-size:13px;opacity:0.9">Loading from: ${this._escapeHtml(scriptUrl)}</div>
          <div style="font-size:12px;opacity:0.7;margin-top:4px">Save and publish to see the app.</div>
        </div>`;
    } else {
      this.domElement.innerHTML = `
        <div style="padding:40px 24px;text-align:center;background:#f3f2f1;border:2px dashed #c8c6c4;border-radius:4px;font-family:Segoe UI,sans-serif">
          <div style="font-size:32px;margin-bottom:12px">&#x1F4DD;</div>
          <div style="font-size:18px;font-weight:600;color:#323130;margin-bottom:8px">CCSD Script Editor</div>
          <div style="font-size:14px;color:#605e5c;margin-bottom:16px">
            Configure this web part to load your custom application.
          </div>
          <div style="font-size:13px;color:#797775">
            Open the property pane to set the <strong>Script URL</strong>.
          </div>
        </div>`;
    }
  }

  private _renderContent(): void {
    const scriptUrl = this.properties.scriptUrl;

    if (!scriptUrl) {
      this.domElement.innerHTML = `
        <div style="padding:20px;text-align:center;color:#605e5c;font-family:Segoe UI,sans-serif">
          <p>No Script URL configured. Edit the web part properties to set one.</p>
        </div>`;
      return;
    }

    // Build the full URL
    const fullUrl = scriptUrl.startsWith('http')
      ? scriptUrl
      : this.context.pageContext.web.absoluteUrl + (scriptUrl.startsWith('/') ? '' : '/') + scriptUrl;

    const height = this.properties.iframeHeight || '100vh';

    // Show loading state
    this.domElement.innerHTML = `
      <div style="display:flex;align-items:center;justify-content:center;height:${this._escapeHtml(height)};font-family:Segoe UI,sans-serif;color:#605e5c">
        Loading application...
      </div>`;

    // Fetch the HTML file content via AJAX (bypasses download headers)
    // then render it in a srcdoc iframe
    const xhr = new XMLHttpRequest();
    xhr.open('GET', fullUrl, true);
    xhr.responseType = 'text';
    xhr.withCredentials = true;
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        let html = xhr.responseText;

        // Use srcdoc iframe — this renders the HTML directly without needing a URL
        // No download headers involved since the content is inline
        const iframe = document.createElement('iframe');
        iframe.style.cssText = 'border:none;width:100%;height:' + height + ';display:block;';
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.srcdoc = html;

        this.domElement.innerHTML = '';
        this.domElement.appendChild(iframe);
      } else {
        this.domElement.innerHTML = `
          <div style="padding:20px;text-align:center;color:#a4262c;font-family:Segoe UI,sans-serif">
            <p><strong>Error loading application</strong></p>
            <p>Failed to fetch ${this._escapeHtml(scriptUrl)} (HTTP ${xhr.status})</p>
            <p style="font-size:12px;color:#605e5c">Make sure the file exists and you have access.</p>
          </div>`;
      }
    };
    xhr.onerror = () => {
      this.domElement.innerHTML = `
        <div style="padding:20px;text-align:center;color:#a4262c;font-family:Segoe UI,sans-serif">
          <p><strong>Network error</strong></p>
          <p>Could not reach ${this._escapeHtml(scriptUrl)}</p>
        </div>`;
    };
    xhr.send();
  }

  private _escapeHtml(str: string): string {
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  protected get dataVersion(): Version {
    return Version.parse('1.0');
  }

  protected getPropertyPaneConfiguration(): IPropertyPaneConfiguration {
    return {
      pages: [
        {
          header: {
            description: 'Configure the Script Editor to load your custom HTML/JavaScript application.'
          },
          groups: [
            {
              groupName: 'Script Source',
              groupFields: [
                PropertyPaneTextField('scriptUrl', {
                  label: 'Script URL',
                  description: 'Path to your HTML file in SiteAssets (e.g., /sites/CCSDAdminSPA/SiteAssets/Scripts/Index.html)',
                  placeholder: '/sites/CCSDAdminSPA/SiteAssets/Scripts/Index.html',
                  multiline: false
                })
              ]
            },
            {
              groupName: 'Display Settings',
              groupFields: [
                PropertyPaneDropdown('iframeHeight', {
                  label: 'App Height',
                  options: [
                    { key: '100vh', text: 'Full viewport height (100vh)' },
                    { key: 'calc(100vh - 50px)', text: 'Full viewport minus header' },
                    { key: '800px', text: '800px' },
                    { key: '600px', text: '600px' },
                    { key: '400px', text: '400px' }
                  ],
                  selectedKey: '100vh'
                })
              ]
            }
          ]
        }
      ]
    };
  }
}
