```plaintext
              ____      __                      ______            __   __                __  
             /  _/___  / /___  ______  ___     / ____/___  ____  / /__/ /_  ____  ____  / /__
             / // __ \/ __/ / / / __ \/ _ \   / /   / __ \/ __ \/ //_/ __ \/ __ \/ __ \/ //_/
           _/ // / / / /_/ /_/ / / / /  __/  / /___/ /_/ / /_/ / ,< / /_/ / /_/ / /_/ / ,<   
          /___/_/ /_/\__/\__,_/_/ /_/\___/   \____/\____/\____/_/|_/_.___/\____/\____/_/|_|  

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
git clone https://github.com/cscott-dev/Intune-Cookbook.git
cd Intune-Cookbook
```

### Importing Configurations

Configuration files are JSON files that have been exported using the [IntuneManagement](https://github.com/Micke-K/IntuneManagement) tool and are imported the same way. To import a configuration, run the **IntuneManagement** tool, connect the tool to the Microsoft Intune tenant, and import the required JSON file. For more information, consult the [Documentation](https://github.com/Micke-K/IntuneManagement?tab=readme-ov-file#import).
