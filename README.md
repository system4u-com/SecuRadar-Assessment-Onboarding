# SecuRadar Assessment Onboarding

This file provides instructions on how to use the provided PowerShell script for onboarding to SecuRadar.

## Prerequisites

Before running the script, ensure you have the following:

- PowerShell 7
- Dedicated Azure Subscription
- An Azure account with appropriate permissions - Global Administrator and Owner of dedicated Azure subscription
- filled variables in `./properties.conf` file

## Usage

1. Download this whole repository to your local machine.
2. Navigate to the directory where the script is located:

    ```powershell
    cd /path/to/this/directory/on/your/computer
    ```

3. Open the `properties.conf` file and fill in necessary variables
4. Open PowerShell as an administrator.
5. Run the script:

    ```powershell
    .\SecuRadar_Assessment_Onboarding.ps1
    ```

6. At the end of the script, send the information provded by the script to your System4u contact.

## Security

Running the script will give access for a group of L3 technicians from System4u to the subscription with the following rights:

- Reader
- Microsoft Sentinel Contributor
- Managed Services Registration assignment Delete Role

Also, the will be eligible for activation of the following roles using the Priviledged Identity Protection:

- Contributor
- Security Reader

## Troubleshooting

If you encounter any issues, ensure the following:

- You have the necessary permissions in your Azure account.
- Your PowerShell session is running with administrative privileges.
- The Azure PowerShell module is up to date.

For further assistance, refer to the official Azure documentation or contact your system administrator.

## Contact

In case of problems, please inform your contact person in System4u.
