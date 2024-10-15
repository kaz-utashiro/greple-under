package App::Greple::Config;

use v5.14;
use warnings;

use Exporter 'import';
our @EXPORT = qw();
our @EXPORT_OK = qw(config getopt split_argv mod_argv);

use Getopt::Long qw(GetOptionsFromArray);
Getopt::Long::Configure qw(bundling);

use List::Util qw(first);

sub new {
    my $class = shift;
    our $config = bless { @_ }, $class;
}

sub load {
    my $obj = shift;
    my($my_argv, $argv) = split_argv(shift);
    getopt($my_argv, $obj) if @$my_argv;
}

######################################################################

sub config {
    while (my($k, $v) = splice @_, 0, 2) {
	my @names = split /\./, $k;
	my $c = our $config // die "config is not initialized.\n";
	my $name = pop @names;
	for (@names) {
	    $c = $c->{$_} // die "$k: invalid name.\n";
	}
	exists $c->{$name} or die "$k: invalid name.\n";
	$c->{$name} = $v;
    }
}

use Getopt::EX::Func;
*arg2kvlist = \&Getopt::EX::Func::arg2kvlist;

sub getopt {
    my($argv, $opt) = @_;
    return if @{ $argv //= [] } == 0;
    GetOptionsFromArray
	$argv,
	"config=s" => sub { config arg2kvlist($_[1]) }
	or die "Option parse error.\n";
}

sub mod_argv {
    my($mod, $argv) = splice @_, 0, 2;
    ($mod, split_argv($argv), @_);
}

sub split_argv {
    my $argv = shift;
    my @my_argv;
    if (@$argv and $argv->[0] !~ /^-M/ and
	defined(my $i = first { $argv->[$_] eq '--' } keys @$argv)) {
	splice @$argv, $i, 1; # remove '--'
	@my_argv = splice @$argv, 0, $i;
    }
    (\@my_argv, $argv);
}

1;
