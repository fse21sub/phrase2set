use warnings;
use strict;
use autodie;

use DBI;
use Config::General;
use File::Copy;
use File::Copy::Recursive  qw(dircopy);
use Encode qw(decode encode); # Core perl module

sub load_graph_file($$){
	my($filepath, $destination_path) = @_;

	copy($filepath, $destination_path) or die "Copy failed: $!";
}

sub load_text_file($$){
	my($filepath, $destination_path) = @_;

	# Load contents of the specified source file into a variable to write to a copy of the file.
	open(my $fh, '<', $filepath) or die "Could not open file '$filepath' $!"; # '<' indicates read mode
	my $file_text = '';
	while (my $row = <$fh>) {
  		chomp $row;
  		$file_text  .= $row."\n";
	}
	$file_text;
	close $fh;

	# Save copied text to destination file
	open(my $fh, '>', $destination_path) or die "Could not open file '$destination_path' $!"; # '>' indicates overwrite mode
	print $fh $file_text;
	close $fh;
}

my $config_path = shift @ARGV;

if (!defined $config_path) {
	$config_path = 'android.conf';
}
die "Config file \'$config_path\' does not exist"
	unless (-e $config_path);

my %config =  Config::General::ParseConfig($config_path);

my $graph_output_dir = $config{graph_input_path};
my $graph_output_dest_dir = $config{graph_output_dest_dir};
my $graph_image_file_name = "graph_image.gif";
my $graph_text_file_name = "graph_text.txt";

# Create a directory hold a copy of text and image of all the top graph output results
unless(-e $graph_output_dest_dir or mkdir $graph_output_dest_dir) {
	die "Unable to create $graph_output_dest_dir";
}	

# Read all posts in the survey directory and copy them into the student copy directory
my $num_of_dirs = 0;
opendir(my $DIR, $graph_output_dir);
while (my $post_id = readdir $DIR ) {
	# The directory iterator returns '.' or '..' sometimes. Ignore those.
	if(not $post_id =~ /[0-9]/){
		next;
	}
	print "Processing post $post_id\n";
	++$num_of_dirs;

	# Create a directory to hold the output files corresponding to the post that was analysed to produce them.
	my $post_id_dir = $graph_output_dest_dir.'/'.$post_id.'/';
	unless(-e $post_id_dir or mkdir $post_id_dir) {
		die "Unable to create $post_id_dir";
	}	

	# Copy the graph image to the newly created post copy folder.
	my $post_output_dir = $graph_output_dir.$post_id.'/';
	my $graph_image_path = $post_output_dir.$config{graph_file_name}.'.gif';	
	load_graph_file($graph_image_path, $post_id_dir.$graph_image_file_name);

	# Copy the graph text to the newly created post copy folder
	my $graph_text_path = $post_output_dir.$config{graph_file_name}.'.txt';	
	load_text_file($graph_text_path, $post_id_dir.$graph_text_file_name)
}
print "$num_of_dirs folders copied\n";
closedir $DIR;


