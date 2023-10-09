# Tests

## Forward

Your project is governed by your philosophy.

I haven't put much philosophical ramblings into project templates
for certain reasons; but the main reason is that building systems
that "just work", "do the right thing", and "require as little
work as possible" should speak for themselves.

Tests break that "fourth wall", and require balance in order to
not encumber the programmer.

I believe this layout allows for tests of arbitrary complexity
ranging from very simple to "if you need something else, at
least you're not starting from a nightmare."

Not all "projects" require a rigid and thorough testing infrastructure.
But, the idea behind all of this "Full Project" template stuff
is that you should be able to create a simple project, and "grow"
without experiencing growing pains.

I do believe that large software package repositories should have
a standard for how automated tests are defined, and run, etc.
I believe that something as simple as "just making sure the program
doesn't have syntax errors" should be sufficient for simple things
that have no substantial risk of being deployed with bugs, or there
is little risk to having been deployed with bugs.

To that end, I will eventually be making testing templates that
automatically work the following scenarios:

* [TAP](https://testanything.org) whereby:
	* Running "prove tests/t" in the top level of the project
	should be sufficient for simple things and for the simple
	examples provided.

## Test Creating Workflow

IMO: Unless you know what you're doing ahead of time, you shouldn't
be doing Test Driven Development, which means you're going to
be writing tests after you have already written a part of your project.

When you test your program(s), you're going to be running the same command
over and over again.

Save that as a script under tests/bin .

If you decide that you want to use something more rigid (like TAP), then
make a tests/t file that calls your script under tests/bin .

## Testing Directory Layout

All of these variables are defined under etc/test_project_paths.bash :

* $test_dir: Tests shall be defined under the project root under "tests".
	* project_dir/tests/ (typically)
* $test_etc_dir - Configuration for how tests should be run, and for tests
themselves.
	* project_dir/tests/etc
* $test_lib_dir - Libraries for testing purposes.
	* project_dir/tests/lib
* $test_bin_dir - Where you put programs that actually do the testing.
	* project_dir/tests/bin
* $test_data_dir - Put (redacted) data files here for testing.
	* project_dir/tests/data
* $test_t_dir - Tests that conform to the [TAP](https://testanything.org) protocol.
You can use this to call your scripts in the $test_bin_dir.
	* project_dir/tests/t

## Other (Useful) Available Variables

* $project_dir - the root of the project
* $project_bin_dir - where your programs live
	* project_dir/src/bin
* $project_lib_dir - your script libraries
	* project_dir/src/lib
* $project_etc_dir - your programs configuration files
	* project_dir/src/etc
* $project_root_etc_dir - configuration files that will be stored under /etc/
	* project_dir/src/root_etc
* $project_input_dir - transient files for using as input
	* project_dir/src/input
* $project_output_dir - directory for storing transient output files
	* project_dir/src/output


