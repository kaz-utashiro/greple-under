package App::Greple::under;
use 5.024;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

App::Greple::under - greple under-line module

=head1 SYNOPSIS

    greple -Munder::line ...

    greple -Munder ... | greple -Munder::line ^

=head1 DESCRIPTION

B<greple>'s B<under> module emphasizes matched text not in the same line
but in the next line without ANSI effect.

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/normal.png">
</p>

=for html <p>
<img width="750" src="https://raw.githubusercontent.com/kaz-utashiro/greple-under/main/images/under-line.png">
</p>

=head1 AUTHOR

Kazumasa Utashiro

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

use App::Greple::Common qw(@color_list);
use Term::ANSIColor::Concise qw(ansi_code);
use Text::ANSI::Fold;
use Text::ANSI::Fold::Util qw(ansi_width);
use Data::Dumper;

$Term::ANSIColor::Concise::NO_RESET_EL = 1;
Text::ANSI::Fold->configure(expand => 1);

my $config = {
    name => 'line',
    "custom-colormap" => 1,
};

my $re;
my %index;

sub prologue {
    return if state $called++;
    @color_list == 0 and die "color table is not available.\n";
    my @ansi = map { ansi_code($_) } @color_list;
    my @ansi_re = map { quotemeta($_) } @ansi;
    %index = map { $ansi[$_] => $_ } keys @ansi;
    my $reset_re = qr/(?:\e\[[0;]*[mK])+/;
    $re = do {
	local $" = '|';
	qr/(?<ansi>@ansi_re) (?<text>[^\e]*) (?<reset>$reset_re)/x;
    };
}

my $space = ' ';
my %marks  = (
    line => [
	"\N{UPPER ONE EIGHTH BLOCK}",
    ],
    number => [ "0" .. "9" ],
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
my @marks = $marks{$config->{name}}->@*;

sub line {
    while (<>) {
	local @_;
	my @under;
	my $pos;
	while (/\G (?<pre>.*?) $re /xgp) {
	    push @_, $+{pre}, $+{text};
	    my $mark = $marks[$index{$+{ansi}} % @marks];
	    push @under,
		$space x ansi_width($+{pre}),
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

1;

__DATA__

option default \
    --prologue &__PACKAGE__::prologue \
    --under-custom-colormap

option --under-line \
    --of &__PACKAGE__::line

option --under-custom-colormap \
    $<move> \
    --cm @ \
    --cm {SGR6;1},{SGR6;2},{SGR6;3} \
    --cm {SGR6;4},{SGR6;5},{SGR6;6} \
    --cm {SGR6;7},{SGR6;8},{SGR6;9}
