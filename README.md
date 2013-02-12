# MdInc

MdInc is a text utility that allows you to suck text from one file into another.

## Installation

Add this line to your application's Gemfile:

    gem 'md_inc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install md_inc

## Usage

MdInc is a simple text inclusion filter intended for use
with markdown and similar text formatting utilities. 
MdInc provides simple 'include this other file' kind
of processing. Using MdInc is straight forwark: Just require
it in and use the process method:

    require 'md_inc'
    
    v = MdInc::TextProcessor.new
    output = v.process 'The quick brown fox'
    
In the simple case like the one above, MdInc simply 
returns the text unchanged. The interesting bit is
when your input text includes commands that MdInc
recognizes. MdInc commands all start with a . in
the first column of a line. The most basic is
`.inc`. Here is some input that includes an `.inc` 
command:

    Here is the first line.
    Now I'm going to include another file.
    .inc 'some_other_file.md'
    And the last line.

Run the file above through MdInc and the output
will include the contents of `some_other_file.md`
embedded in it.

You can also pluck out only part of the included
file based on a pair of regular expressions:

    Here we are going to include only part of file1,
    just the lines between START and END.
    .between(/START/, /END/, inc('file1'))
    Note that the lines matching START and END are
    not included in the output.

And you can exclude lines based on a regular expression:

    Pull in the contents of file1, skipping any
    lines that contain DONTWANT
    .skip(/DONTWANT/, inc('file1'))

As you can probably guess from this last example,
the MdInc dot commands are really just inline Ruby
code that gets executed during file processing.
Because of this it's easy to extend MdInc with
your own commands. See the specs for an example.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
