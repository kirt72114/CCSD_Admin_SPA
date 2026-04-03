# CCSD Script Editor — SPFx Web Part

A SharePoint Framework (SPFx) web part that acts as a modern Script Editor, allowing you to load the CCSD All-Things Administrative SPA on modern SharePoint pages.

## Features

- **Iframe Mode** (recommended): Loads your app via URL in an iframe — full isolation, no conflicts
- **Inline Mode**: Injects HTML/CSS/JS directly into the page DOM
- Configurable iframe height (full viewport, fixed px, etc.)
- Edit mode placeholder with configuration instructions
- Works on SharePoint Online modern pages, Teams tabs, and full-page apps

## Prerequisites

- **Node.js 16.x or 18.x** (SPFx 1.18.2 does NOT support Node 20+)
- npm 8+
- SharePoint Online site with App Catalog access

### Install Node 18 (if needed)

```powershell
# Using nvm for Windows (https://github.com/coreybutler/nvm-windows)
nvm install 18.20.2
nvm use 18.20.2
node --version  # Should show v18.x.x
```

## Build & Package

```powershell
# 1. Navigate to the project directory
cd spfx-script-editor

# 2. Install dependencies
npm install

# 3. Bundle for production
gulp bundle --ship

# 4. Create the .sppkg package
gulp package-solution --ship
```

The package file will be at: `sharepoint/solution/ccsd-script-editor.sppkg`

## Deploy to SharePoint

### Step 1: Upload to App Catalog

1. Go to your SharePoint Admin Center → **More features** → **Apps** → **App Catalog**
   - Or create a site-level app catalog: `Add-SPOSiteCollectionAppCatalog -Site https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA`
2. Upload `ccsd-script-editor.sppkg` to the **Apps for SharePoint** library
3. When prompted, check **"Make this solution available to all sites"** and click **Deploy**

### Step 2: Add to Your Site

1. Go to `https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA`
2. Click the **gear icon** → **Add an app**
3. Find **"CCSD Script Editor"** and click **Add**

### Step 3: Add to a Page

1. Navigate to (or create) a modern SharePoint page
2. Click **Edit** on the page
3. Click **+** to add a web part → search for **"CCSD Script Editor"**
4. Click the web part's **pencil icon** to open the property pane
5. Configure:
   - **Use Iframe**: Yes (recommended)
   - **Script URL**: `/sites/CCSDAdminSPA/SiteAssets/Scripts/Index.html`
   - **Iframe Height**: Full viewport height
6. **Save and publish** the page

## Upload Your App HTML

Make sure your `Index.html` is uploaded to SiteAssets:

```powershell
Connect-PnPOnline -Url "https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA" -Interactive
Add-PnPFile -Path ".\Index.html" -Folder "SiteAssets/Scripts"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `gulp` not found | Run `npm install -g gulp-cli` |
| Build errors on Node 20+ | Switch to Node 18: `nvm use 18` |
| Web part not visible | Ensure the app is added to your site (Step 2) |
| Iframe blank/error | Check the Script URL path is correct and the file exists in SiteAssets |
| "Custom scripts not allowed" | Enable custom scripts: `Set-SPOSite -Identity <url> -DenyAddAndCustomizePages 0` |

## Making a Full-Page App

For a full-page experience (no SharePoint chrome), create a **Single Part App Page**:

1. Go to **Site contents** → **New** → **Page** → choose **Single Part App Page** (if available)
2. Select the **CCSD Script Editor** web part
3. This gives you the full viewport with no SharePoint navigation bars
