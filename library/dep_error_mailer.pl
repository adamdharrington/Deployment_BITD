#!/usr/bin/perl
# fslyne 2013
use Net::SMTP;

my $subj="Mailer message - ".convdatetimenow();
my $mailserver="smtp.o2.ie";
my $to=@ARGV[0];
my $from=$to;
my $m=@ARGV[1];
$mailserver=($m) ? $m : $mailserver;

# set up access to mailserver
$smtp = Net::SMTP->new($mailserver);
$smtp->mail($from);
$smtp->to($to);
$smtp->data();
$smtp->datasend("From: $from\n");
$smtp->datasend("To: $to\n");
$smtp->datasend("Subject: $subj\n");
$smtp->datasend("\n");
while(<STDIN>) {
        $smtp->datasend($_);
}
$smtp->dataend();
$smtp->quit;

exit;

sub convdatetimenow {
return convdatetime(time());
}

sub convdatetime {
my $time = shift;
return convdate($time)." ".convtime($time);
}

sub convdate {
my $time = shift;
my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime($time);
$year = "1900"+$year;
$mon = $mon+1; $mon = "0".$mon if ($mon<10);
$day = "0".$day if ($day<10) ;
return "$year-$mon-$day";
}


sub convtime {
my $time = shift;
my ($sec,$min,$hour,$day,$mon,$year,$wday,$yday,$isdst)=localtime($time);
$hour= "0".$hour if ($hour<10);
$min = "0".$min  if ($min <10);
$sec = "0".$sec  if ($sec <10);
return "$hour:$min:$sec";
}
