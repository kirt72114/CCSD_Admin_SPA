import { Version } from '@microsoft/sp-core-library';
import {
  type IPropertyPaneConfiguration,
  PropertyPaneTextField,
  PropertyPaneToggle,
  PropertyPaneDropdown
} from '@microsoft/sp-property-pane';
import { BaseClientSideWebPart } from '@microsoft/sp-webpart-base';

export interface IScriptEditorWebPartProps {
  scriptUrl: string;
  scriptContent: string;
  useIframe: boolean;
  iframeHeight: string;
}

export default class ScriptEditorWebPart extends BaseClientSideWebPart<IScriptEditorWebPartProps> {

  public render(): void {
    // Clear previous content
    this.domElement.innerHTML = '';

    if (this.displayMode === 1) {
      // Display mode = Edit (1)
      this._renderEditPlaceholder();
    } else {
      // Display mode = Read (0)
      this._renderContent();
    }
  }

  private _renderEditPlaceholder(): void {
    const scriptUrl = this.properties.scriptUrl;
    const scriptContent = this.properties.scriptContent;
    const hasContent = !!(scriptUrl || scriptContent);

    if (hasContent && this.properties.useIframe && scriptUrl) {
      // Show a preview in edit mode too
      this._renderContent();
      // Add edit overlay
      const overlay = document.createElement('div');
      overlay.style.cssText = 'position:absolute;top:0;left:0;right:0;padding:8px 16px;background:rgba(0,120,212,0.9);color:#fff;font-size:13px;font-family:Segoe UI,sans-serif;z-index:1000;display:flex;align-items:center;gap:8px;';
      overlay.innerHTML = '<span style="font-weight:600">&#x270E; CCSD Script Editor</span><span style="opacity:0.8">— Edit web part properties to configure</span>';
      this.domElement.style.position = 'relative';
      this.domElement.insertBefore(overlay, this.domElement.firstChild);
    } else {
      this.domElement.innerHTML = `
        <div style="padding:40px 24px;text-align:center;background:#f3f2f1;border:2px dashed #c8c6c4;border-radius:4px;font-family:Segoe UI,sans-serif">
          <div style="font-size:32px;margin-bottom:12px">&#x1F4DD;</div>
          <div style="font-size:18px;font-weight:600;color:#323130;margin-bottom:8px">CCSD Script Editor</div>
          <div style="font-size:14px;color:#605e5c;margin-bottom:16px">
            ${hasContent ? 'Content configured. Switch to read mode to view.' : 'Configure this web part to load your custom application.'}
          </div>
          <div style="font-size:13px;color:#797775">
            Open the property pane to set a <strong>Script URL</strong> (iframe) or paste <strong>Script Content</strong> (inline HTML/JS).
          </div>
        </div>`;
    }
  }

  private _renderContent(): void {
    const scriptUrl = this.properties.scriptUrl;
    const scriptContent = this.properties.scriptContent;

    if (scriptUrl && this.properties.useIframe) {
      // Iframe mode — load the URL in a full iframe
      const height = this.properties.iframeHeight || '100vh';
      this.domElement.innerHTML = `
        <iframe
          src="${this._escapeHtml(scriptUrl)}"
          style="border:none;width:100%;height:${this._escapeHtml(height)};display:block;overflow:hidden"
          allowfullscreen
          sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-popups-to-escape-sandbox allow-downloads allow-modals"
        ></iframe>`;
    } else if (scriptContent) {
      // Inline mode — inject HTML/JS directly into the DOM
      this.domElement.innerHTML = scriptContent;
      this._executeScripts(this.domElement);
    } else {
      this.domElement.innerHTML = `
        <div style="padding:20px;text-align:center;color:#605e5c;font-family:Segoe UI,sans-serif">
          <p>No content configured. Edit the web part properties to add a Script URL or Script Content.</p>
        </div>`;
    }
  }

  /**
   * Execute any <script> tags that were injected via innerHTML
   * (innerHTML doesn't execute scripts by default)
   */
  private _executeScripts(element: HTMLElement): void {
    const scripts = element.querySelectorAll('script');
    for (let i = 0; i < scripts.length; i++) {
      const oldScript = scripts[i];
      const newScript = document.createElement('script');

      // Copy attributes
      for (let j = 0; j < oldScript.attributes.length; j++) {
        const attr = oldScript.attributes[j];
        newScript.setAttribute(attr.name, attr.value);
      }

      // Copy content
      newScript.textContent = oldScript.textContent;

      // Replace old with new to trigger execution
      if (oldScript.parentNode) {
        oldScript.parentNode.replaceChild(newScript, oldScript);
      }
    }
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
            description: 'Configure the Script Editor web part to load your custom HTML/JavaScript application.'
          },
          groups: [
            {
              groupName: 'Script Source',
              groupFields: [
                PropertyPaneToggle('useIframe', {
                  label: 'Use Iframe',
                  onText: 'Yes — load URL in an iframe (recommended)',
                  offText: 'No — inject content inline'
                }),
                PropertyPaneTextField('scriptUrl', {
                  label: 'Script URL',
                  description: 'Full URL to your HTML file (e.g., /sites/CCSDAdminSPA/SiteAssets/Scripts/Index.html). Used when "Use Iframe" is enabled.',
                  placeholder: '/sites/CCSDAdminSPA/SiteAssets/Scripts/Index.html',
                  multiline: false
                }),
                PropertyPaneTextField('scriptContent', {
                  label: 'Script Content',
                  description: 'Paste HTML/CSS/JavaScript directly. Used when "Use Iframe" is disabled.',
                  placeholder: '<div>Your HTML here...</div><script>console.log("hello");</script>',
                  multiline: true,
                  rows: 15
                })
              ]
            },
            {
              groupName: 'Display Settings',
              groupFields: [
                PropertyPaneDropdown('iframeHeight', {
                  label: 'Iframe Height',
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
