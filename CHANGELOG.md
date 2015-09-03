# Changelog

Next release
---------
- Remove `java` cookbook dependency. This was not used, except for testing in kitchen. For testing purposes, the
  dependency was moved to the test fixture cookbook instead. The purpose of this cookbook was not to manage Java.
- Change relative service command to fully-qualified path. This fixes systemd service manager.est
- Remove old service templates.

0.5.1
---------
- Fix incorrect examples in README.md

0.5.0
---------
- Add auto-detection of related configuration resources. See README.md for
  more details. NOTE: This is a breaking change because some attributes were 
  removed.

0.4.1
---------
- Added proper matchers for apache_tomcat_service

0.4.0
---------
- Modify service to use poise_service. Fixes #7
  NOTE: This is technically a breaking change. See README.md for more information. 

0.3.2
---------
- Fixed issue with tomcat bundle wars exploding into nested dir

0.3.1
---------
- Fixed default manifest creation issue with tomcat bundle wars

0.3.0
---------
- Default Tomcat webapp bundle management. Thanks to @klangrud

0.2.1
---------
- Fix bug in server.xml with UserDatabase realm

0.2.0
---------
- Add LICENSE and license headers. Fixes #1
- Add ChefSpec matchers. Fixes #3
- Fix README 'bug'. Fixes #4
- Fix entity bug in server.xml. Fixes #5
- Fix style. Fixes #6
- Fix runit service cookbook name bug.

0.1.0
---------
- Initial release
