#!/usr/bin/perl

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

my $dbhost='127.0.0.1'; my $dbport=3306;
my $dsn="DBI:mysql:dbtest;host=$dbhost;port=$dbport";
$dbh = DBI->connect($dsn, 'dbtestuser', 'dbpassword'
                ) || die "Could not connect to database: $DBI::errstr";
$sth = $dbh->prepare("insert into custdetails(name,address) values(?,?)");
$sth->execute($name,$address);
}

sub showDB {
my $dbhost='127.0.0.1'; my $dbport=3306;
my $dsn="DBI:mysql:dbtest;host=$dbhost;port=$dbport";
$dbh = DBI->connect($dsn, 'dbtestuser', 'dbpassword'
                ) || die "Could not connect to database: $DBI::errstr";
$sth = $dbh->prepare("select * from custdetails");
$sth->execute();
while (my $result = $sth->fetchrow_hashref()) {
        print $result->{'name'}," ",$result->{'address'},"<p>";
}
}
