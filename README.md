minetest-lib-ModLib
===================

Library for Minetest mods and libraries to load other libraries with version
requirements and one-time loading

General
=======

This is NOT a "mod"; it is a LIBRARY for use by mods and other libraries.  That
means it does not modify how Minetest works in any way, but provides a useful
API to help mods do so.  This particular library is used purely for managing
the loading of other libraries, and has no dependencies.

Installation
============

The file "lib/ModLib.lua" in this package should be installed in a "lib"
subdirectory of the main directory of the mod that depends on it.  If other
mods under the same game also include versions of ModLib, only one instance of
any given version will be loaded.  This is the same for any libraries that
ModLib is used to load as well.

Other libraries the mod depends on, and that will be loaded using ModLib,
should also be included in this "lib" subdirectory.  Their filenames must have
the form "LibName_version.lua". LibName is the name of the library, which must
start with a letter and contain only letters and digits.  And version is a
version number like "x.y.z" (with any number of components) where the periods
are replaced with dashes ("x-y-z").  Due to a definiciency in the current
version of Lua, another file called "ModLib_list.txt" must exist in the "lib"
subdirectory and must contain the name of each library file on a separate line,
with no extra characters or empty lines.  In Linux this list can be generated
using the command "ls -1 >ModLib_list.txt" from within the "lib" subdirectory.

The ONLY exception to including the version number in the name of the library
file is for "ModLib.lua", and that is because it includes special boostrap code
and a version of it must be loadable from any mod that loads a library, without
depending on a specific version during bootstrap.

For example, if a mod "my_mod" depends on LibMod 1.0 and version 2.3 of another
mod library "MyLib" and is installed to:

   .../mods/minetest/my_mod

then the following files must exist:

   .../mods/minetest/my_mod/lib/ModLib_list.txt
   .../mods/minetest/my_mod/lib/ModLib.lua
   .../mods/minetest/my_mod/lib/MyLib_2-3.lua

and ModLib_list.txt must contain the following lines:

   ModLib_list.txt
   ModLib.lua
   MyLib_2-3.lua

(The inclusion of "ModLib_list.txt" and "ModLib.lua" in this file is optional.)

Use
===

All libraries a mod depends on should be included with the mod.  This ensures
these libraries are available to the mod whether or not they are also included
in other mods, and whether or not the version in any other mods is incompatible
with the version this mod needs.  The exception would be if the mod depends on
another mod and uses a library the dependency includes in a limited fashion
rather than being directly dependent on details of the library API.

In order to load one of these dependent libraries from your mod through ModLib,
first you must bootstrap ModLib, then add your "lib" subdirectory to its
library load path, then ask it to load your library, specifying what versions
of the library are compatible with your mod.  For the above example using
ModLib 1.0 and MyLib 2.3 this would look like:

   -- Bootstrap ModLib
   local MOD_NAME = minetest.get_current_modname()
   local MOD_PATH = minetest.get_modpath(MOD_NAME)
   local ModLib = dofile(MOD_PATH.."/lib/ModLib.lua")

   -- Add to the library path:
   ModLib.addDir(MOD_PATH.."/lib")

   -- Load the dependent library.  Note that this MyLib 2.3 OR LATER.  If the
   -- exact version were required, or if a range of versions were acceptable,
   -- then a second (maximum) version number would be added to the call.
   local MyLib = ModLib.load("MyLib", "2.3")

Note carefully the use of local variable rather than globals.  This MUST always
be how a mod or library loads another library, in order to allow multiple
versions to coexist.  Note, however, that you may add the module API as a field
of the module's own API in order to use it from other files or even other mods
(see the note above about libraries included by dependent mods).  So my_mod
could then do this:

   my_mod.MyLib = MyLib

which would allow my_mod.MyLib to be accessed from any Lua file in the mod or
any other mod that depends on it.

The use of ModLib from another library is only slightly different.  The library
should assume that the mod that is loading it has added any library directories
to the load path already, so it can skip this step.  So from a library this
looks like:

   -- Bootstrap ModLib
   local LOADING_MOD = minetest.get_current_modname()
   local LOADING_MOD_PATH = minetest.get_modpath(MOD_NAME)
   local ModLib = dofile(LOADING_MOD_PATH.."/lib/ModLib.lua")

   -- Load the dependent library, with a minimum version of 1.0.
   local MyOtherLib = ModLib.load("MyOtherLib", "1.0")

   local MyLib = {}
   ...
   return MyLib

Now let's assume that MyLib is updated a few times and everything works up to
version 3.0, but then 3.1 comes along and gets included in a bunch of mods, and
we discover that this update breaks my_mod.  Until we can update my_mod to
account for the changes, we make a one-line change to make sure it will not
load anything above version 3.0 for my_mod:

   local MyLib = ModLib.load("MyLib", "2.3", "3.0")

The other modules that can use version 3.1 will continue to use it and will not
be affected by this change.

Advanced Use
============

What if newer versions of ModLib come out, and your module depends on newer
features?  Well, there must always be an unversioned "lib/ModLib.lua" that any
mod may load during bootstrap (from any mod that might load the library).
However, ModLib itself acts as another library that it can load by version, and
it is perfectly okay to have both the unversioned file name (with any actual
version in it) and versioned filenames in the load path.  So just go ahead and
include your newer version of ModLib twice in the mod, with the two paths
"lib/ModLib.lua" and "lib/ModLib_x-y-z.lua".

What about more complex version dependencies?  The API currently allows a
minimum version of a library to be specified, a maximum version, or both.  What
if there are multiple ranges, or one particular plagued version that we want to
exclude?  In future versions of ModLib the API may allow for more complex
version specification, but for now you can take advantage of the builtin error
handling mechanism of Lua to successively try to load acceptable versions or
ranges.

For example, take the above scenario and assume that MyLib comes out with
version 3.2 that fixes the issues my_mod had with version 3.1.  How can we load
verison 3.2 if it is available, and otherwise load versions 2.3 through 3.0?
First, we could choose to obsolete use of the older versions and switch my_mod
to ship with version 3.2 instead of the old 2.3 to ensure it is available.  But
we could also do this:

   local status, MyLib = pcall(ModLib.load, "MyLib", "3.2")
   if not (status and MyLib) then
      status, MyLib = pcall(ModLib.load, "2.3", "3.0")
   end
   if not (status and MyLib) then
      error("No compatible version of MyLib found")
   end

Suggested Version Dependencies
==============================

How specific you make the version requirements is really up to you.  It depends
on how you want to balance stability versus flexibility.  For maximum
stability, you should require only versions that you have thoroughly tested
your mod or library against.  For more flexibility, allowing future library
versions that might fix defects or enhanced behavior can be enabled by only
requiring a minimum version, at least until such time as up update to the
library breaks things.

A middle ground could be to require exact versions of unstable or uncertain
libraries, but allow libraries from more consistent developers to update
without limit, or until some large minor version number (e.g. 2.99999) but not
the next major version (e.g. 3.0).

Testing
=======

A couple of unit tests are included with ModLib.  From the base directory of
the package, you can run the following, and should get the listed output:

   $ lua test/ModLib_test.lua

   ModLib tests PASSED

   $ lua test/ModLib_Version.lua

   ModLib.Version tests PASSED

These tests can also be run within Minetest by including the ModLib library in
a mod in the normal way, adding the "test" directory and all contents from this
package as a subdirectory in the mod's main directory, and running the
following from the mod's code:

   local MOD_NAME = minetest.get_current_modname()
   local MOD_PATH = minetest.get_modpath(MOD_NAME)
   dofile(MOD_PATH.."test/ModLib_test.lua")
   dofile(MOD_PATH.."test/ModLib_Version_test.lua")

