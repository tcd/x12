# Change Log

12/27/19 - release 1.7.0
* Add `custom_file` param to `X12.Parser.new` for using local XML definitions

11/26/19 - release 1.6.3
* Update 855.xml

10/25/19 - release 1.6.2
* Fix invalid yard doc comments

10/25/19 - release 1.6.1
* Fix invalid yard doc comments

10/25/19 - release 1.6.0
* Update tests from `test/unit` to `minitest`
* Add `simplecov` gem for test coverage
* Replace the 850.xml file
* Fix license
* Rename to `tcd_x12`

11/2/15 - release 1.5.3, 1.5.2
* Updated 837p.xml Loop 20102AB to include REF segments
* fixed misspelling

4/16/15 - release 1.5.1
* Added inpsect method to loop class to resolve infinite loop due to changes with inspect and to_s methods in ruby 2.0.0
* Thank you to Wylan for troubleshooting and providing the fix

11/8/14 - release 1.5.0
* converted from ReXML to LibXML for speed improvement on XML parsing

9/14/13 - release 1.4.7
* Added 276 / 277 transaction messages
* Fixed issue with 835.xml file

4/15/13 - release 1.4.5
* Factories now enforce minimum sizes - wbajzek contributed
* 270Interchange.xml updated ST segment's field list - wbajzek contributed
* Test updated for minimum size - wbajzek contributed

3/22/13 - releases 1.4.1 - 1.4.3
* Fix errors in the 835.xml file

3/11/13 - release 1.4.0
* Added X12 definitions for 271 transaction
* Renamed the gem to be all lower case so Rails and other frameworks autoload the project as a gem
* Added an each method to segments to simplify looping through repeating segments