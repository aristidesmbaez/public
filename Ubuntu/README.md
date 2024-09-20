# Ubuntu VDI Scripts
Two scripts where created to address a few needs for Ubuntu VDIs being used for remote development. The Ubuntu VDIs where designed to be used by developers with out sudo access. Things like docker needed to be configured to run in rootless mode and some addtional commands need to be run after the VDI is booted for the first time as they where created from a master golden image. 

Vdisudo.sh was designed to be run as a cronjob that is scheduled to run on boot. It is configured to run in system level and to run only once per machine.

vdiuser.sh was designed to run in user space using a .desktop file placed in /etc/xdg/autostart/. It is used to set some user level settings and deploy rootless docker.