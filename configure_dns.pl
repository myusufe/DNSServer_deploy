#!/bin/perl

#
# muhammad.efendi@ge.com
# Version 1.0
# March 2015
#

if ( @ARGV != 1 )
{
	usage();
	exit;
}

#
# initial setting
#
$named_conf_file = "/etc/named.conf";
$named_directory = "/var/named";
$backup_dir = "./backup/";
$zone_fwd_template = "mydomain.com.fwd.zone";
$zone_rev_template = "mydomain.com.rev.zone";

#
# input the data
#

if($ARGV[0] eq "master"){

	print "Domain Name (ex: mydomain.com): ";
	$domain_name = <STDIN>;
	chomp($domain_name);

	print "Primary DNS Server Hostname (ex: ns1.mydomain.com): ";
	$primary_dns_hostname = <STDIN>;
	chomp($primary_dns_hostname);

	print "Primary DNS Server IP Address : ";
	$primary_dns_ipaddress = <STDIN>;
	chomp($primary_dns_ipaddress);

	print "Secondary DNS Server Hostname (ex: ns2.mydomain.com): ";
	$secondary_dns_hostname = <STDIN>;
	chomp($secondary_dns_hostname);

	print "Secondary DNS Server IP Address : ";
	$secondary_dns_ipaddress = <STDIN>;
	chomp($secondary_dns_ipaddress);

	#backup the DNS data
	backup_data($named_conf_file);

	# create new named.conf file
	create_named_conf_master($named_conf_file,$domain_name,$primary_dns_hostname,$primary_dns_ipaddress,$secondary_dns_hostname,$secondary_dns_ipaddress);

}
elsif($ARGV[0] eq "slave"){

        print "Domain Name (ex: mydomain.com): ";
        $domain_name = <STDIN>;
        chomp($domain_name);

        print "Primary DNS Server IP Address : ";
        $primary_dns_ipaddress = <STDIN>;
        chomp($primary_dns_ipaddress);

        print "Secondary DNS Server IP Address : ";
        $secondary_dns_ipaddress = <STDIN>;
        chomp($secondary_dns_ipaddress);

	#backup the DNS data
        backup_data($named_conf_file);

	# create new named.conf file
        create_named_conf_slave($named_conf_file,$domain_name,$primary_dns_ipaddress,$secondary_dns_ipaddress);

}
else{
	usage();
	exit;
}


sub backup_data{

	$get_date = create_date();
	$backup_file = $_[0].".".$get_date;
	system("cp -frp $_[0] $backup_dir$backup_file");
	print "Backup $_[0] file as ".$backup_dir.$backup_file." file\n";

}

sub create_named_conf_master{

	$named_conf_file = $_[0];
	$domain_name = $_[1]; 
	$primary_dns_hostname = $_[2];
	$primary_dns_ipaddress = $_[3];
	$secondary_dns_hostname = $_[4];
	$secondary_dns_ipaddress = $_[5];

	system("cp ./template/named.conf_master $named_conf_file");
	system("chown root:named $named_conf_file");	
	system("chmod 640 $named_conf_file");

	($a,$b,$c,$d) = split (/\./, $primary_dns_ipaddress);
	($e,$f,$g,$h) = split (/\./, $secondary_dns_ipaddress);

	$tmp_ip = "$a.$b.$c";
	$tmp_ip_reverse = "$c.$b.$a";
 
	# make /etc/named.conf file
	system("sed -i -- 's/mydomain.com/$domain_name/g' $named_conf_file");
	system("sed -i -- 's/192.168.56.105/$primary_dns_ipaddress/g' $named_conf_file");
	system("sed -i -- 's/192.168.56.107/$secondary_dns_ipaddress/g' $named_conf_file");
	system("sed -i -- 's/192.168.56.0/$tmp_ip.0/g' $named_conf_file");
	system("sed -i -- 's/56.168.192/$tmp_ip_reverse/g' $named_conf_file");
	
	# make /var/named/mydomain.com.fwd.zone file

	($first1,$second1)  = split (/\./,$primary_dns_hostname,2);
	($first2,$second2)  = split (/\./,$secondary_dns_hostname,2);
	
	system("cp template/mydomain.com.fwd.zone $named_directory/$domain_name.fwd.zone");
	system("sed -i -- 's/ns1.mydomain.com/$primary_dns_hostname/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/ns2.mydomain.com/$secondary_dns_hostname/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/192.168.56.105/$primary_dns_ipaddress/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/192.168.56.107/$secondary_dns_ipaddress/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/ns1/$first1/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/ns2/$first2/g' $named_directory/$domain_name.fwd.zone");	
	system("sed -i -- 's/mydomain.com/$second1/g' $named_directory/$domain_name.fwd.zone");	

	# make /var/named/mydomain.com.rev.zone file

	system("cp template/mydomain.com.rev.zone $named_directory/$domain_name.rev.zone");
	system("sed -i -- 's/ns1.mydomain.com/$primary_dns_hostname/g' $named_directory/$domain_name.rev.zone");        
        system("sed -i -- 's/ns2.mydomain.com/$secondary_dns_hostname/g' $named_directory/$domain_name.rev.zone");      
        system("sed -i -- 's/192.168.56.105/$primary_dns_ipaddress/g' $named_directory/$domain_name.rev.zone");
        system("sed -i -- 's/192.168.56.107/$secondary_dns_ipaddress/g' $named_directory/$domain_name.rev.zone");       
        system("sed -i -- 's/ns1/$first1/g' $named_directory/$domain_name.rev.zone");
        system("sed -i -- 's/ns2/$first2/g' $named_directory/$domain_name.rev.zone");
        system("sed -i -- 's/mydomain.com/$second1/g' $named_directory/$domain_name.rev.zone");
        system("sed -i -- 's/105/$d/g' $named_directory/$domain_name.rev.zone");
        system("sed -i -- 's/107/$h/g' $named_directory/$domain_name.rev.zone");
	
}

sub create_named_conf_slave{

        $named_conf_file = $_[0];
        $domain_name = $_[1];
        $primary_dns_ipaddress = $_[2];
        $secondary_dns_ipaddress = $_[3];

        system("cp ./template/named.conf_slave $named_conf_file");
        system("chown root:named $named_conf_file");
        system("chmod 640 $named_conf_file");

        ($a,$b,$c,$d) = split (/\./, $primary_dns_ipaddress);
        ($e,$f,$g,$h) = split (/\./, $secondary_dns_ipaddress);

        $tmp_ip = "$a.$b.$c";
        $tmp_ip_reverse = "$c.$b.$a";

        # make /etc/named.conf file
        system("sed -i -- 's/mydomain.com/$domain_name/g' $named_conf_file");
        system("sed -i -- 's/192.168.56.105/$primary_dns_ipaddress/g' $named_conf_file");
        system("sed -i -- 's/192.168.56.107/$secondary_dns_ipaddress/g' $named_conf_file");
        system("sed -i -- 's/192.168.56.0/$tmp_ip.0/g' $named_conf_file");
        system("sed -i -- 's/56.168.192/$tmp_ip_reverse/g' $named_conf_file");
}

sub create_date{

# grab the current time
my @now = localtime();

my $timeStamp = sprintf("%04d%02d%02d%02d%02d%02d", 
                        $now[5]+1900, $now[4]+1, $now[3],
                        $now[2],      $now[1],   $now[0]);

return $timeStamp;
}

sub usage{

	print ("Please input right argument as:\n");
	print (" $0 master/slave\n");
}

