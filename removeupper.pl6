use v6;
use lib 'lib';
use Stomp::Config;
use Stomp::Index;
use Stomp::Key;
use Stomp::Utils;
use JSON::Tiny;

=begin EXPLAIN

Remove anything from the index that has an uppercase key
You should probably run casefix.pl6 before this or you may lose data

=end EXPLAIN

sub remove-case-sensitive(Stomp::Key $key, Str $sitename) {
    my $index = Stomp::Index::get($key);
    say "removing $sitename";
    $index{$sitename} :delete;
    if not $index{$sitename.lc} :exists {
        # this isn't fatal as you may have removed a site, which would only
        # remove the lowercase index key
        # so just say what it is so it can be checked
        # you are backing up data files before running scripts from a repo
        # called "bad-stomp-scripts" right?
        warn "DANGER DANGER there is no lowercase $sitename";
    }
    write($key.encrypt(to-json($index)));
}

sub write(Str $encjson) {
    my $fh = xopen($Stomp::Config::Index);
    xwrite($fh, $encjson);
    xclose($fh);
}

my $key = Stomp::Key.new();
my $password = Stomp::Utils::ask-password();
$key.unlock($password);

my $index = Stomp::Index::get($key);

for $index.kv -> $sitename, $filename {
    if $sitename ~~ m/ <[A..Z]> / {
        remove-case-sensitive($key, $sitename);
    }
}

# vim: ft=perl6
