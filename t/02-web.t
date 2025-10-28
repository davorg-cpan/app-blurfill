use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use HTTP::Response;
use File::Basename;

use App::BlurFill::Web;
my $app = App::BlurFill::Web->to_app;

my $image = "t/test.jpg";
plan skip_all => "Test image $image not found" unless -e $image;

# Test GET / route
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $res = $cb->(GET '/');
        is($res->code, 200, 'Got 200 OK from GET /');
        like($res->content, qr/<!DOCTYPE html>/i, 'Response contains HTML doctype');
        like($res->content, qr/<title>BlurFill/i, 'Response contains BlurFill title');
        like($res->content, qr/<form[^>]+action="\/blur"/i, 'Response contains form with action="/blur"');
        like($res->content, qr/<form[^>]+method="POST"/i, 'Response contains form with method="POST"');
        like($res->content, qr/<form[^>]+enctype="multipart\/form-data"/i, 'Response contains form with multipart encoding');
        like($res->content, qr/<input[^>]+type="file"[^>]+name="image"/i, 'Response contains file input for image');
        like($res->content, qr/<input[^>]+type="number"[^>]+name="width"/i, 'Response contains number input for width');
        like($res->content, qr/<input[^>]+type="number"[^>]+name="height"/i, 'Response contains number input for height');
    };

# Test POST /blur route
open my $fh, '<', $image or die "Can't read image: $!";
binmode $fh;
my $content = do { local $/; <$fh> };

my $req = POST '/blur',
    Content_Type => 'form-data',
    Content => [
        image => [ undef, basename($image), Content => $content, 'Content-Type' => 'image/jpeg' ],
        width => 800,
        height => 450,
    ];

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $res = $cb->($req);
        is($res->code, 200, 'Got 200 OK from /blur');
        like($res->header('Content-Disposition'), qr/filename=".*?_blur\.jpg"/, 'Content-Disposition header looks good');
        like($res->content, qr/.{100,}/s, 'Response has image content');
    };

done_testing;

