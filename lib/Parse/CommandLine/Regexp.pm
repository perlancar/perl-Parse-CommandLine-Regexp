package Parse::CommandLine::Regexp;

# DATE
# VERSION

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(parse_command_line);

sub _remove_backslash {
    my $s = shift;
    $s =~ s/\\(.)/$1/g;
    $s;
}

sub parse_command_line {
    my $line = shift;

    my @words;
    my $after_ws;
    $line =~ s!(                                                         # 1) everything
                  (")((?: \\\\|\\"|[^"])*)(?:"|\z)(\s*)               |  #  2) open "  3) content  4) space after
                  (')((?: \\\\|\\'|[^'])*)(?:'|\z)(\s*)               |  #  5) open '  6) content  7) space after
                  ((?: \\\\|\\"|\\'|\\\s|[^"'\s])+)(\s*)              |  #  8) unquoted word  9) space after
                  \s+
              )!
                  if ($2) {
                      if ($after_ws) {
                          push @words, _remove_backslash($3);
                      } else {
                          push @words, '' unless @words;
                          $words[$#words] .= _remove_backslash($3);
                      }
                      $after_ws = $4;
                  } elsif ($5) {
                      if ($after_ws) {
                          push @words, _remove_backslash($6);
                      } else {
                          push @words, '' unless @words;
                          $words[$#words] .= _remove_backslash($6);
                      }
                      $after_ws = $7;
                  } elsif (defined $8) {
                      if ($after_ws) {
                          push @words, _remove_backslash($8);
                      } else {
                          push @words, '' unless @words;
                          $words[$#words] .= _remove_backslash($8);
                      }
                      $after_ws = $9;
                  }
    !egx;

    @words;
}

1;
# ABSTRACT: Parsing string like command line

=head1 DESCRIPTION

This module is an alternative to L<Parse::CommandLine>, using regexp instead of
per-character parsing technique employed by Parse::CommandLine, and which might
offer better performance in Perl (see benchmarks in
L<Bencher::Scenario::CmdLineParsingModules>).

L</"parse_command_line">, the main routine, basically split a string into
"words", with whitespaces as delimiters while also taking into account quoting
using C<"> (double-quote character) and C<'> (single-quote character) as well as
escaping using C<\> (backslash character). This splitting is similar to, albeit
simpler than, what a shell like bash does to its command-line string.


=head1 FUNCTIONS

=head2 parse_command_line

Usage:

 my @words = parse_command_line($str);


=head1 SEE ALSO

L<Parse::CommandLine>

L<Text::ParseWords>, which allows you to specify what characters to use as
delimiters.

C<parse_cmdline> in L<Complete::Bash>, which also takes into account
non-whitespace word-breaking character such as C<|>.

L<Text::CSV> and friends
