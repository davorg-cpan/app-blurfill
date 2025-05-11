use v5.40;
use experimental 'class';

class App::BlurFill::CLI {
  our $VERSION = '0.0.1';

  use Getopt::Long;
  use File::Basename;
  use App::BlurFill;

  method run {
    my %opts;
    GetOptions(\%opts, 'width:i', 'height:i', 'output:s');

    my $in = shift @ARGV or die "Usage: blurfill [--width w] [--height h] [--output o] image_file\n";

    my $blur = App::BlurFill->new(
        file   => $in,
        %opts,
    );

    my $outfile = $blur->process;
    say "Wrote $outfile";
  }
}
