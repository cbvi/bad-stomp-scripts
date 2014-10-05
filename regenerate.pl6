use v6;
use lib 'lib';
use Stomp::Key;
use Stomp::Data;
use Stomp::Index;
use Stomp::Utils;
use JSON::Tiny;

=begin EXPLANATION

Reencrypts all the data with a new key

=end EXPLANATION

sub swap-index-new {
    $Stomp::Config::Index ~= '.new';
}

sub swap-index-old {
    $Stomp::Config::Index .= subst('index.new', 'index');
}

sub swap-key-new {
    $Stomp::Config::Key ~= '.new';
}

sub swap-key-old {
    $Stomp::Config::Key .= subst('stompkey.new', 'stompkey');
}

xchmod(0o700, $Stomp::Config::KeyDir);

my $key = Stomp::Key.new();
my $password = Stomp::Utils::ask-password();
$key.unlock($password);

my $newkey = Stomp::Key.new();
$newkey.rekey($password.encode);

my Buf $enc = Stomp::Utils::random(1024 * 8);
my $fh = xopen($Stomp::Config::Key ~ '.new');
xwrite($fh, $newkey.encrypt($enc));
xclose($fh);

$fh = xopen($Stomp::Config::Index ~ '.new');
$newkey.rekey($enc);
xwrite($fh, $newkey.encrypt('{ }'));
xclose($fh);

my $index = Stomp::Index::get($key);

for $index.kv -> $sitename, $filename {
    my $data = Stomp::Data::get($key, $sitename);
    Stomp::Data::remove($key, $sitename);
    swap-key-new();
    swap-index-new();
    Stomp::Data::add($newkey, $data<sitename>, $data<username>);
    Stomp::Data::edit($newkey, $data<sitename>, $data);
    say "added {$data<sitename>}";
    swap-key-old();
    swap-index-old();
}

xunlink($Stomp::Config::Key);
xunlink($Stomp::Config::Index);

rename($Stomp::Config::Key ~ '.new', $Stomp::Config::Key);
rename($Stomp::Config::Index ~ '.new', $Stomp::Config::Index);

xchmod(0o400, $Stomp::Config::Key);
xchmod(0o500, $Stomp::Config::KeyDir);

# vim: ft=perl6
