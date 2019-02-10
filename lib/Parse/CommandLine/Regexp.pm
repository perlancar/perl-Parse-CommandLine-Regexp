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
