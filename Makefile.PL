use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'App::BlurFill',
    VERSION_FROM => 'lib/App/BlurFill.pm',
    LICENSE      => 'perl',
    AUTHOR       => 'dave@perlhacks.com',
    ABSTRACT     => 'Blurred background fill image processor',
    PREREQ_PM    => {
        'Imager'         => 0,
        'File::Basename' => 0,
        'File::Temp'     => 0,
        'Test::More'     => 0,
    },
    MIN_PERL_VERSION => '5.040',
    EXE_FILES        => [ 'bin/app.psgi', 'bin/blurfill' ],
);
