use v6;
use lib 'lib';
use CSV::Parser;
use Stomp::Utils;
use Stomp::Key;
use Stomp::Data;

=begin DANGER

1Password appears to export with some fields missing for some entries, no
attempt has been made to handle this in this script

use as your own risk

=end DANGER

if not @*ARGS {
    say "No filename specified";
    exit(0);
}

my $filename = @*ARGS.shift;
my $password = Stomp::Utils::ask-password();
my Stomp::Key $key = Stomp::Key.new();
$key.unlock($password);

my $fh = open($filename);

my $parser = CSV::Parser.new( file_handle => $fh, contains_header_row => 1 );


loop {
    my %lines = $parser.get_line();
    exit(0) if not %lines;

    my Hash $add = Stomp::Data::add(
        $key, %lines<title>, %lines<username>, %lines<password>); 

    my %data =
        sitename => $add<sitename>,
        username => $add<username>,
        password => $add<password>,
        notes    => %lines<notes>,
        url      => %lines<url>;
    my %ed = Stomp::Data::edit($key, $add<sitename>, %data);
    say "Added {$add<sitename>} (%ed<username>)";
    say "%ed<url> - %ed<notes>";
    say();
}

# vim: ft=perl6
