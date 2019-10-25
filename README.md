# X12

![Ruby Version](https://img.shields.io/badge/Ruby->=1.9.1-red.svg)
![GitHub](https://img.shields.io/github/license/tcd/x12)

Changes welcome, especially new document types or better tests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'x12'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install x12
```

## Documentation

### Wiki Page: https://github.com/mjpete3/x12/wiki

## Major deficiencies

- Validation is not implemented.
- Field types are ignored.
- No access methods for composites’ fields.

# Acknowledgments

The authors of the project were inspired by the following works:

- The Perl X12 parser by Prasad Poruporuthan, search.cpan.org/~prasad/X12-0.09/lib/X12/Parser.pm
- The Ruby port of the above by Chris Parker, rubyforge.org/projects/x12-parser/
- This project originated from App Design's X12 parser.

- Project was forked by Sean Walberg, creating version 1.2.0 in April 2012.
- Project was forked by Marty Petersen in November 2012, creating pd_x12.

# License

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA