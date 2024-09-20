## Zscaler root certificate script
With Zscaler Client Connector doing SSL inspection, several applications and command line tools require Zscaler's root certificate to be added to the application’s respective certificate trust store to not run into SSL errors. 

This script was created to try to automate that process for known applications. It was designed to run post Zscaler Client Connector install and was also packaged and made available through JAMF self service.