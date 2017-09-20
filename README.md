# JitenshaInstaller
Powershell module for automatic installation of applications on Windows

This module is created for automatic installation programs by various ways. Now it support installation of exe, msi, msp, msu installators and chocolatey packages. Main application area of this script module - is computers on wich we have not permanent access, like my mom's PC, or domain workstations. In my case I use Sheduled Task which start script under administrator. This allows to keep the necessary set of programs up to date without much expense.

In current condition script search information about packages in Windows Registry - HKEY_LOCAL_MACHINE\SOFTWARE\Jitensha
