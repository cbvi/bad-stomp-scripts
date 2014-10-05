use v6;
use lib 'lib';
use Stomp::Index;
use Stomp::Key;
use Stomp::Utils;

=begin EXPLAIN

Lists every key in the index which is different from the sitename and has no
way of being displayed from stomp itself (since it's only really useful for
debugging).

=end EXPLAIN

my $key = Stomp::Key.new();
my $password = Stomp::Utils::ask-password();
$key.unlock($password);

my $index = Stomp::Index::get($key);

for $index.kv -> $sitename, $filename {
    say $sitename;
}

# vim: ft=perl6
