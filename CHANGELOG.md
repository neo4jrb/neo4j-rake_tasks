# Change Log
All notable changes to this project will be documented in this file.
This file should follow the standards specified on [http://keepachangelog.com/]
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]

## [0.7.14] - 09-21-2017

### Fixed

- Fixed issue with query string in NEO4J_DIST

## [0.7.13] - 09-20-2017

### Fixed

- Added `NEO4J_DIST` environment variable to allow for downloading from custom URL (neccessitated by Neo4j, Inc. removing public link).  (thanks @klobuczek / see #39)

## [0.7.11] - 04-25-2017

### Fixed

- Removed `colored` gem as dependency (fewer dependencies and less monkey patching are both good.  Thanks @dominicsayers / see #38)

## [0.7.11] - 03-18-2017

### Fixed

- Bug which caused auth to not be disabled in Neo4j 3.1.2

## [0.7.10] - 12-23-2016

### Fixed

- Support for `neo4j:config` in Neo4j >= 3.1.0 (see #37, thanks to @ernestoe)

### Skip a few...

## [0.6.1] - 06-03-2016

### Removed `require` statements for `httparty` (thanks again ProGM!)

## [0.6.0] - 06-03-2016

### Changed

- Removed dependency on HTTParty (thanks ProGM / see #28)

### Added

- Progress bar for Neo4j install (thanks ProGM / see #28)

## [0.5.6] - 05-30-2016

### Fixed

- Mixed up paths from 0.5.5 fix

## [0.5.5] - 05-29-2016

### Fixed

- Fixed reset task for Neo4j 3.0 (see #27)
- Make `config` task reset Bolt port as well as HTTP / HTTPS (see #27)

## [0.4.2] - 02-17-2016

### Fixed

- Matching variables / values in `properties` (see #21, thanks to bobmazanec)
- Default port in config task to 7474

## [0.4.0] - 01-13-2016

### Added

- In addition to ability to `community-latest`, added ability to install `community-(stable|rc|release-candidate|milestone)` as defined in config
- Ability to give an argument to `ServerManager#stop` with a timeout to force shutdown

## [0.3.0] - 09-27-2015

### Added
- Add `shell` rake task.  Start Neo4j if it is not already started (and stop afterward)

## [0.2.0] - 09-27-2015

### Added
- Added `console` task (thanks to darrin-wortlehock via #13)

## [0.1.0] - 09-24-2015

### Changed
- Use rubyzip rather than zip

### Fixed
- Fix `rake neo4j:reset_yes_i_am_sure` not actually resetting the db

## [0.0.8] - 08-17-2015

### Fixed

- Lack of an explicit `require 'rake'` could cause errors in projects using this gem.

## [0.0.1]-[0.0.7]
- Early releases. Moved tasks from `neo4j-core` gem, refactored.
