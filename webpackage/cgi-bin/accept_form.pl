#!/usr/bin/perl

my $DB_username="replace_username";
my $DB_password="replace_password";
my $DB_name="replace_name";
my $DB_host="replace_host";
my $DB_port="replace_port";

use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use DBI;

print header, start_html("Accept Form");

my $name=param('name');
my $address=param('address');
print h3("inserting name:$name and address:$address into Database");
insertDB($name,$address);
print h3("Showing the contents of the Database");
showDB();

print end_html;

exit;

sub insertDB {
my $name = shift;
my $address =shift;

my $dsn="DBI:mysql:$DB_name;host=$DB_host;port=$DB_port";
$dbh = DBI->connect($dsn, $DB_username, $DB_password
                ) || die "Could not connect to database: $DBI::errstr";
$sth = $dbh->prepare("insert into custdetails(name,address) values(?,?)");
$sth->execute($name,$address);
}

sub showDB {
my $dsn="DBI:mysql:$DB_name;host=$DB_host;port=$DB_port";
$dbh = DBI->connect($dsn, $DB_username, $DB_password
                ) || die "Could not connect to database: $DBI::errstr";
$sth = $dbh->prepare("select * from custdetails");
$sth->execute();
while (my $result = $sth->fetchrow_hashref()) {
        print $result->{'name'}," ",$result->{'address'},"<p>";
}
}
