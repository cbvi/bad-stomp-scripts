use v6;
use lib 'lib';
use Stomp::Index;
use Stomp::Key;

=begin EXPLANATION

Find out what sitename corresponds to a given datafile

=end EXPLANATION

if @*ARGS.elems < 1 {
    die "pass filename as an argument";
}

my $datafile = @*ARGS.shift;

my $key = Stomp::Key.new();
my $password = Stomp::Utils::ask-password();
$key.unlock($password);

my $index = Stomp::Index::get($key);

for $index.kv -> $sitename, $filename {
    if $filename eq $datafile {
        say $sitename;
        exit(0);
    }
}

# vim: ft=perl6
