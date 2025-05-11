use v5.40;

package App::BlurFill::Web;
use Dancer2;

our VERSION = '0.0.1';

use File::Temp qw(tempfile tempdir);
use App::BlurFill;

post '/blur' => sub {
  my $upload = upload('image')
    or return status 400, { error => 'Missing image file' };

  my $orig_name = $upload->filename;
  my ($name, $path, $ext) =
    File::Basename::fileparse($orig_name, qr/\.[^.]*$/);

  return status 400, { error => 'Uploaded file must have a file extension' }
    unless $ext;

  my $format = lc $ext;
  $format =~ s/^\.//;

  my %mime = (
    jpg  => 'image/jpeg',
    jpeg => 'image/jpeg',
    png  => 'image/png',
    gif  => 'image/gif',
  );

  return status 400, { error => "Unsupported file format: .$format" }
    unless exists $mime{$format};

  my $content_type = $mime{$format};

  my $width  = query_parameters->get('width')  || 650;
  my $height = query_parameters->get('height') || 350;

  my $in_dir = File::Temp::tempdir;
  my $in_path = "$in_dir/$name$ext";
  $upload->copy_to($in_path);

  my $outfile;
  eval {
    my $blur = App::BlurFill->new(
      file   => $in_path,
      width  => $width,
      height => $height,
    );
    $outfile = $blur->process;
  } or return status 500, { error => "Processing failed: $@" };

  my ($out_name) = File::Basename::fileparse($outfile);

  response_header 'Content-Disposition' => qq{attachment; filename="$out_name"};
  send_file(
    $outfile,
    system_path => 1,
    content_type => $content_type,
    content_disposition => "attachment; filename=\"$out_name\"",
  );
};

