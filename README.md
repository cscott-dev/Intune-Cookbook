```plaintext
              ____      __                      ____                                           
             /  _/___  / /___  ______  ___     / __ \___  _________  __  _______________  _____
             / // __ \/ __/ / / / __ \/ _ \   / /_/ / _ \/ ___/ __ \/ / / / ___/ ___/ _ \/ ___/
           _/ // / / / /_/ /_/ / / / /  __/  / _, _/  __(__  ) /_/ / /_/ / /  / /__/  __(__  ) 
          /___/_/ /_/\__/\__,_/_/ /_/\___/  /_/ |_|\___/____/\____/\__,_/_/   \___/\___/____/  
                                                                                                   
```

This repository contains scripts, applications, configurations, and other Intune resources for managing devices across various platforms including macOS, Windows, Linux, iOS, and Android.

## Contents

This repository contains the following resources for each **operating** system:

```plaintext
├───Android
│   └───Configurations
├───iOS
│   └───Configurations
├───Linux
│   ├───Applications
│   ├───Configurations
│   └───Scripts
├───macOS
│   ├───Applications
│   ├───Configurations
│   └───Scripts
└───Windows
    ├───Applications
    ├───Configurations
    └───Scripts
        ├───Compliance Scripts
        ├───Platform Scripts
        └───Remediations
```

## Getting Started

To get started with using these resources, clone the repository and navigate to the relevant directory for your platform.

```sh
git clone https://github.com/cscott-dev/Intune-Resources.git
cd Intune-Resources
```

### Importing Configurations

Configuration files are JSON files that have been exported using the [IntuneManagement](https://github.com/Micke-K/IntuneManagement) tool and are imported the same way. To import a configuration, run the **IntuneManagement** tool, connect the tool to the Microsoft Intune tenant, and import the required JSON file. For more information, consult the [Documentation](https://github.com/Micke-K/IntuneManagement?tab=readme-ov-file#import).

