Norm
====

This is a proof of concept framework for creating executable documentation as
defined by the book Specification by Example.

Prerequisites
-------------
  * Ruby 1.9.3p125 and above

Installation
------------
  * Clone this repo

How to give it a try
--------------------
Use `ruby norm` to execute the documentation. Use `ruby runtests` to run the tests

Directory Structure
-------------------
  * `directives/requirements` - Contains high-level requirements
  * `directives/test_cases` - Contains the underlying test cases for each requirement
  * `directives/utilities` - Contains steps, functions, and other ruby code that can be called only from within the test cases.
  * `lib` - Contains the Norm framework
  * `test` - Framework unit tests. Run with `ruby runtests`.