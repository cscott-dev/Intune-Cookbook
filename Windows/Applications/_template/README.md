# {Application Name}

| Field                 | Content                                                                                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Description**       | {Description}                                                                                                                   |
| **Publisher**         | {Publisher}                                                                                                                     |
| **Version**           | {Version}                                                                                                                       |
| **Developer**         | Chris Scott (Aryon Pty Ltd)                                                                                                     |
| **Icon**              | <img src="https://github.com/cscott-dev/Intune-Resources/blob/main/Windows/Applications/_template/icon.png?raw=true" width=100> |
| **Install Command**   | `powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File {InstallScript}`                                              |
| **Uninstall Command** | `powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File {UninstallScript}`                                            |
| **Run As**            | [System/User]                                                                                                                   |
| **Detection**         | {DetectionMethod} - {DetectionPath}                                                                                             |

## Template Checklist

- [ ] **Install & Uninstall Scripts** have been modified and renamed to `Install-{AppName}` and `Uninstall-{AppName}.ps1`
      respectively.
- [ ] An **App Icon** has been created using an application like https://photopea.com/ to the below specifications:
   - The application icon should be a `.png` file sized 512 x 512 pixels. The application icon itself (within the file) should be 256 x 256 pixels, and be displayed in the center of the image. This allows for a transparent border in the image which improves consistency within the Company Portal.
- [ ] The **README** file has been updated to include preperation information and further notes/processes as required
      by the applications deployment process. This includes, but is not limited to:
   - [ ] Update the **Prerequisites** section.
      > If an installer is required to be downloaded for the package, note it here.
   - [ ] Update the **Deployment Process** section.
   - [ ] Update the **Notes** section.
      > This should include information such as: *Requires access to `https[://]downloadurl[.]com` to download
         installer*.
   - [ ] **Delete this section**

## Prerequisites

1. **This Repository**\
   Clone or download this repository.
2. **Microsoft Win32 Content Prep Tool**\
   Download the tool from [this link](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool).

## Deployment Process

### 1. Prepare

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
5. Configure the install and uninstall commands using the same table as the previous step. Select **Next**.
6. Configure the detection method using the same table as the previous step. Select **Next**.
7. Under **Assignments**, assign the app to the appropriate groups or users.

## Notes

-   Use [Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview) or something similar to test local installation prior to deployment. (**NOTE:** You will need to create a `%ProgramData%\Microsoft\IntuneManagementExtension\Logs` folder prior to installation for it to work, due to the logging).
