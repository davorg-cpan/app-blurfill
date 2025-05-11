use v5.40;
use experimental 'class';

class App::BlurFill {
    our $VERSION = '0.0.1';

    use Imager;
    use File::Basename 'fileparse';
    use File::Temp 'tempdir';

    field $file    :param;
    field $width   :param = 650;
    field $height  :param = 350;

    field $output  :param = do {
      my ($name, $path, $ext) = fileparse($file, qr/\.[^.]*$/);

      my $dir = tempdir(CLEANUP => 1);

      my $filename = "${name}_blur$ext";

      "$dir/$filename";
    };

    field $imager  :param = Imager->new(file => $file);

    method process {
        my $background = $imager->copy;

        $background = $background->scale(xpixels => $width);
        my $bg_height = $background->getheight;
        $background = $background->crop(
            top    => ($bg_height / 2) - ($height / 2),
            bottom => ($bg_height / 2) + ($height / 2),
        );
        $background->filter(type => 'gaussian', stddev => 15);

        my $img = $imager->scale(ypixels => $height);
        my $img_width = $img->getwidth;

        $background->compose(src => $img, left => ($width / 2) - ($img_width / 2));
        $background->write(file => $output, type => 'png') or die $background->errstr;

        return $output;
    }
}
