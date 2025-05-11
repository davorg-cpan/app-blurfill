use v5.40;
use experimental 'class';

class App::BlurFill::CLI {
    use Getopt::Long;
    use File::Basename;
    use App::BlurFill;

    method run {
        my %opts;
        GetOptions(\%opts, 'width=i', 'height=i');
        $opts{width}  //= 650;
        $opts{height} //= 350;

        my $in = shift @ARGV or die "Usage: blurfill [--width w] [--height h] image_file\n";

        my ($name, $path, $ext) = fileparse($in, qr/\.[^.]*$/);
        my $out = "${path}${name}_blur$ext";

        my $blur = App::BlurFill->new(
            file   => $in,
            width  => $opts{width},
            height => $opts{height},
            output => $out,
        );

        my $outfile = $blur->process;
        say "Wrote $outfile";
    }
}
