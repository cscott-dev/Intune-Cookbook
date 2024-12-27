# # Script - Custom Default Wallpaper

| Field                 | Content                                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Description**       | Sets a custom default wallpaper that can be changed by the end-user.                                                                                                 |
| **Publisher**         | Aryon Pty Ltd                                                                                                                                                        |
| **Version**           | 0.1                                                                                                                                                                  |
| **Developer**         | Chris Scott (Aryon Pty Ltd)                                                                                                                                          |
| **Icon**              | <img src="https://github.com/cscott-dev/Intune-Cookbook/blob/main/Windows/Applications/%23%20Script%20-%20Custom%20Default%20Wallpaper/icon.png?raw=true" width=100> |
| **Install Command**   | `powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File Install-CustomDefaultWallpaper.ps1`                                                                |
| **Uninstall Command** | `cmd.exe /c`                                                                                                                                                         |
| **Install Behaviour** | User                                                                                                                                                                 |
| **Detection**         | File - `%SystemDrive%\Users\%Username%\AppData\Local\Wallpaper.jpg`                                                                                                  |

## Prerequisites

1. **This Repository**\
   Clone or download this repository.
2. **Microsoft Win32 Content Prep Tool**\
   Download the tool from [this link](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool).
3. **Custom Wallpaper**\
   A customer wallpaper with the filetype `.jpg`, with a number of different aspect ratios (optional).

## Deployment Process

### 1. Prepare

1. Download this folder from the repository.
2. Move your custom wallpaper(s) into the `\Wallpapers` directory using the aspect ratio (e.g. `16x9`, `32x9`, etc.) as the name of the file. Supported aspect ratios are below:

> [!IMPORTANT]
> A file named `16x9.jpg` **must** exist in the `\Wallpapers` directory for the script to work.

### 2. Package

1. Use the [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) and
   convert the folder into an `.intunewin` package:
    - Open **PowerShell**/**Command Prompt** and navigate to the directory containing the utility.
    - Run `IntuneWinAppUtil.exe -c <SourceFolder> -s <InstallScript> -o <OutputFolder>` (replace `<SourceFolder>` with the folder containing the package, `<InstallScript>` with the name of the installation script, and `<OutpuitFolder>` with the folder to output the `.intunewin` file to).

### 3. Deploy

1. Go to **Microsoft Intune** (https://intune.microsoft.com/) and navigate to **Apps > All Apps > Add**.
2. Select the **App Type** as **Windows App (Win32)** and click **Select**.
3. Upload the `.intunewin` file generated in the previous step.
4. Configure the app details using the table at the top of this document. Upload the `icon.png` file in this repository as the application icon. Select **Next**.
5. Configure the install and uninstall commands, as well as the install behaviour, using the same table as the previous step. Select **Next**.
6. Configure the detection method using the same table as the previous step. Select **Next**.
7. Under **Assignments**, assign the app to the appropriate groups or users.

## Notes

-   Use [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview) or something similar to test local installation prior to deployment. (**NOTE:** You will need to create a `%ProgramData%\Microsoft\IntuneManagementExtension\Logs` folder prior to installation for it to work, due to the logging).
