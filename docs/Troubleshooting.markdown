#Troubleshooting

## App crashes upon start up

If the app crashes with the following error:

    LSOpenURLsWithRole() failed with error -10810 for the file ...

This is a very general error and can be caused by a number of things. Known root causes are:

1. Bug in the app you are launching
2. Bug in HotCocoa

If the app fails with the following error:

    BridgeSupport Preview required for this installation.
    Get the latest version from: http://www.macruby.org/files/

Do it to it.

Sometimes debug information will be available in the Console (/Applications/Utilities/Console.app), so you should check in there first. Failing that, you will need to rely on your general debugging skills to find the reason.