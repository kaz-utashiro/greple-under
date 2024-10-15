package App::Greple::under;
use 5.024;
use warnings;

our $VERSION = "0.99";

=encoding utf-8

=head1 NAME

App::Greple::under - greple under-line module

=head1 SYNOPSIS

    greple -Munder::line ...

    greple -Munder::mise ... | greple -Munder::bake

=head1 DESCRIPTION

This module is intended to clarify highlighting points without ANSI
sequencing when highlighting by ANSI sequencing is not possible for
some reason.

The following command searches for a paragraph that contains all the
words specified.

    greple 'license agreements software freedom' LICENSE -p

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/normal.png">
</p>

By default, the emphasis should be indicated by underlining it on the
next line.

    greple -Munder::line 'license agreements software freedom' LICENSE -p

Above command will produce output like this:

 ┌───────────────────────────────────────────────────────────────────────┐
 │   The license agreements of most software companies try to keep users │
 │       ▔▔▔▔▔▔▔ ▔▔▔▔▔▔▔▔▔▔         ▔▔▔▔▔▔▔▔                             │
 │ at the mercy of those companies.  By contrast, our General Public     │
 │ License is intended to guarantee your freedom to share and change free│
 │                                       ▔▔▔▔▔▔▔                         │
 │ software--to make sure the software is free for all its users.  The   │
 │ ▔▔▔▔▔▔▔▔                   ▔▔▔▔▔▔▔▔                                   │
 │ General Public License applies to the Free Software Foundation's      │
 │ software and to any other program whose authors commit to using it.   │
 │ ▔▔▔▔▔▔▔▔                                                              │
 │ You can use it for your programs, too.                                │
 └───────────────────────────────────────────────────────────────────────┘

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/under-line.png">
</p>

If you want to process the search results before underlining them,
process them in the C<-Munder::mise> module and then pass them through
the C<-Munder::bake> module.

    greple -Munder::mise ... | ... | greple -Munder::bake

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/mise-bake.png">
</p>

=head1 SEE ALSO

L<App::Greple>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use Exporter 'import';
our @EXPORT_OK = qw(%config &config &finalize);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

use App::Greple::Common qw(@color_list);
use Term::ANSIColor::Concise qw(ansi_code);
use Text::ANSI::Fold;
use Text::ANSI::Fold::Util qw(ansi_width);
use Hash::Util qw(lock_keys);
use Data::Dumper;

$Term::ANSIColor::Concise::NO_RESET_EL = 1;
Text::ANSI::Fold->configure(expand => 1);

our %config = (
    type => 'eighth',
    space => ' ',
    "custom-colormap" => 1,
);
lock_keys %config;

my %marks  = (
    eighth   => [ "\N{UPPER ONE EIGHTH BLOCK}" ],
    half     => [ "\N{UPPER HALF BLOCK}" ],
    overline => [ "\N{OVERLINE}" ],
    macron   => [ "\N{MACRON}" ],
    caret    => [ "^" ],
    sign     => [ "+", "-" ],
    number   => [ "0" .. "9" ],
    alphabet => [ "a" .. "z", "A" .. "Z" ],
    block => [
	"\N{UPPER ONE EIGHTH BLOCK}",
	"\N{UPPER HALF BLOCK}",
	"\N{FULL BLOCK}",
    ],
    vertical => [
	"\N{BOX DRAWINGS LIGHT VERTICAL}",
	"\N{BOX DRAWINGS LIGHT DOUBLE DASH VERTICAL}",
	"\N{BOX DRAWINGS LIGHT TRIPLE DASH VERTICAL}",
	"\N{BOX DRAWINGS LIGHT QUADRUPLE DASH VERTICAL}",
	"\N{BOX DRAWINGS HEAVY VERTICAL}",
	"\N{BOX DRAWINGS HEAVY DOUBLE DASH VERTICAL}",
	"\N{BOX DRAWINGS HEAVY TRIPLE DASH VERTICAL}",
	"\N{BOX DRAWINGS HEAVY QUADRUPLE DASH VERTICAL}",
    ],
    up => [
	"\N{BOX DRAWINGS LIGHT UP}",
	"\N{BOX DRAWINGS LIGHT UP AND HORIZONTAL}",
	"\N{BOX DRAWINGS UP LIGHT AND HORIZONTAL HEAVY}",
	"\N{BOX DRAWINGS HEAVY UP}",
	"\N{BOX DRAWINGS HEAVY UP AND HORIZONTAL}",
	"\N{BOX DRAWINGS UP HEAVY AND HORIZONTAL LIGHT}",
	"\N{BOX DRAWINGS UP SINGLE AND HORIZONTAL DOUBLE}",
	"\N{BOX DRAWINGS UP DOUBLE AND HORIZONTAL SINGLE}",
	"\N{BOX DRAWINGS DOUBLE UP AND HORIZONTAL}",
    ],
);

my $re;
my %index;
my @marks;

sub prepare {
    @color_list == 0 and die "color table is not available.\n";
    my @ansi = map { ansi_code($_) } @color_list;
    my @ansi_re = map { s/\\\e/\\e/gr } map { quotemeta($_) } @ansi;
    %index = map { $ansi[$_] => $_ } keys @ansi;
    my $reset_re = qr/(?:\e\[[0;]*[mK])+/;
    $re = do {
	local $" = '|';
	qr/(?<ansi>@ansi_re) (?<text>[^\e]*) (?<reset>$reset_re)/x;
    };
    @marks = $marks{$config{type}}->@*;
}

sub line {
    prepare() if not $re;
    while (<>) {
	local @_;
	my @under;
	my $pos;
	while (/\G (?<pre>.*?) $re /xgp) {
	    push @_, $+{pre}, $+{text};
	    my $mark = $marks[$index{$+{ansi}} % @marks];
	    push @under,
		$config{space} x ansi_width($+{pre}),
		$mark  x ansi_width($+{text});
	    $pos = pos;
	}
	if (not defined $pos) {
	    print;
	    next;
	}
	if ($pos < length($_)) {
	    push @_, substr($_, $pos);
	}
	print join '', @_;
	print join '', @under, "\n";
    }
}

sub config {
    while (my($k, $v) = splice @_, 0, 2) {
	my @names = split /\./, $k;
	my $c = \%config;
	my $name = pop @names;
	for (@names) {
	    $c = $c->{$_} // die "$k: invalid name.\n";
	}
	exists $c->{$name} or die "$k: invalid name.\n";
	$c->{$name} = $v;
    }
}

sub getopt {
    use Getopt::EX::Func;
    *arg2kvlist = \&Getopt::EX::Func::arg2kvlist;
    my($argv, $opt) = @_;
    return if @{ $argv //= [] } == 0;
    use Getopt::Long qw(GetOptionsFromArray);
    Getopt::Long::Configure qw(bundling);
    GetOptionsFromArray($argv, "config=s" => sub { config arg2kvlist($_[1]) } )
	or die "Option parse error.\n";
}

sub mod_argv {
    use List::Util qw(first);
    my($mod, $argv) = @_;
    my @my_argv;
    if (@$argv and $argv->[0] !~ /^-M/ and
	defined(my $i = first { $argv->[$_] eq '--' } keys @$argv)) {
	splice @$argv, $i, 1; # remove '--'
	@my_argv = splice @$argv, 0, $i;
    }
    ($mod, \@my_argv, $argv);
}

sub finalize {
    our($mod, $my_argv, $argv) = mod_argv @_;
    getopt $my_argv, \%config;
}

1;

__DATA__

option --under-line \
    --pf &__PACKAGE__::line

option --under-custom-colormap \
    $<move> \
    --cm @ \
    --cm {SGR26;1},{SGR26;2},{SGR26;3} \
    --cm {SGR26;4},{SGR26;5},{SGR26;6} \
    --cm {SGR26;7},{SGR26;8},{SGR26;9}
