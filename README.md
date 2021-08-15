# VUnitRunner

This project is meant to be a simple front end for unit tests written with `vunit test`.
Goals are to provide a simple commandline interface, that will output which tests are run, and what their results are. This should be possible, in a format that is easy to consume by a client, so it can possibly integrate with IDE plugins, etc.
In time there will possibly also be a simple standalone GUI.

## Technical details

This runner should mere make use of the API exposed by [libvunit](https://github.com/rasmus91/libvunit)
Basically all the 'diffult' logic should be there, and this shall merely expose/dictate in which order the calls are made.

