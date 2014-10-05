use v6;
use lib 'lib';
use Stomp::Data;
use Stomp::Key;
use Stomp::Utils;
use Stomp::Index;

=begin EXPLAIN

This script will convert all index keys to lowercase if you have somehow
ended up with index keys that contain uppercase characters. A possible
cause of this is using an older version of stomp that did not enforce
lower-case index keys.

Run removeupper.pl6 after this to get rid of any bad keys

=end EXPLAIN

my $password = Stomp::Utils::ask-password();
my $key = Stomp::Key.new();
$key.unlock($password);

my $index = Stomp::Index::get($key);

for $index.kv -> $sitename, $filename {
    say "removing $sitename";
    # this will only work if the key is already lowercase
    # only doing this to clean up
    # run removeupper.pl6 after this to get the upper/mixed case keys
    Stomp::Index::remove($key, $sitename);
    say "adding {$sitename.lc}";
    Stomp::Index::update($key, $sitename.lc, $filename);
}


# vim: ft=perl6
