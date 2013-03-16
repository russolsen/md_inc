# MdInc

MdInc is a text utility that allows you to suck text from one file into another.

## Installation

Add this line to your application's Gemfile:

    gem 'md_inc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install md_inc

**Note that with version 0.3.0 the API for adding
new commands has changed. You command functions
should be ordinary methods, not module methods
as before.**

## Usage

MdInc is a simple text inclusion filter intended for use
with markdown and similar text formatting utilities. 
MdInc provides simple 'include this other file' kind
of processing. Using MdInc is straightforward: Just require
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

Along with .commands there are also ..commands. The
difference is that ..command can handle inline text.
Here's an example that makes all the lines uppercase:

    ..upcase_content
    some text
    that will
    become uppercase
    ..end

If your command starts with an .., md\_inc will gather up
all of the following lines until it hits a ..end and
makes those lines available to the command via the
`content` method.

As you can probably guess from the examples,
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
