use warnings;
use strict;
use autodie;

use DBI;
use Config::General;
use HTML::Entities;
use File::Copy;
use File::Copy::Recursive  qw(dircopy);
use Encode qw(decode encode); # Core perl module
use Regexp::Common;
use html; # Local module
use logger; # local module

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'android.conf';
}
die "Config file \'$config_path\' does not exist"
	unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

# File name of the file whose link needs to be replaced
my $index_file_name = "index.html";

#open(my $fh, '<', $index_file_name);
# Build the file body
#my $index_file_body;
#while (my $row = <$fh>) {
#	chomp $row;
#	$index_file_body .= $row."\n";
#}
#close($fh);

my $index_file_header = 
"<!DOCTYPE html>
<html>
<style>
th, td {
	 vertical-align: text-top;
	 min-width: 20px;
}
</style>
<body>
";

my $index_file_footer = "
</body>
</html>\n";

my $index_table = '
<table align="center" border="1" width="80%">
	<tr height="30px">
		<th>#</th>
		<th>Original Textual Post</th>
		<th>Extracted Keywords</th>
		<th>Candidate Elements</th>
		<th>Code Template</th>
		<th>Graph</th>
	</tr>';

$index_table .= "\n</table>\n";

my $index_file_body = $index_file_header.$index_table.$index_file_footer;

logger->log_value($index_file_body);
